#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
M=/etc/kubernetes/manifests/kube-apiserver.yaml
apiserver_reset || exit 1
mkdir -p /root/mock2 /etc/kubernetes/audit /var/log/kubernetes/audit
cat > /etc/kubernetes/audit/policy.yaml <<'EOF'
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"]
rules:
- level: None
  users: ["system:apiserver", "system:kube-scheduler", "system:kube-controller-manager", "system:kube-proxy"]
- level: None
  userGroups: ["system:nodes"]
- level: None
  resources:
  - group: "coordination.k8s.io"
    resources: ["leases"]
- level: None
  nonResourceURLs: ["/healthz*", "/readyz*", "/livez*", "/version", "/metrics"]
- level: Metadata
EOF
sed -i '/- kube-apiserver$/a\    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml\n    - --audit-log-path=/var/log/kubernetes/audit/audit.log\n    - --audit-log-maxbackup=1\n    - --audit-log-maxsize=50' $M
sed -i '0,/^    volumeMounts:$/s##    volumeMounts:\n    - mountPath: /etc/kubernetes/audit\n      name: audit-policy\n      readOnly: true\n    - mountPath: /var/log/kubernetes/audit\n      name: audit-log#' $M
sed -i '0,/^  volumes:$/s##  volumes:\n  - hostPath:\n      path: /etc/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-policy\n  - hostPath:\n      path: /var/log/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-log#' $M
echo "Enabling audit logging on the API server (restart takes up to ~2 min) ..."
wait_apiserver 240 || { echo "API server did not come back - run ./mock.sh 2 5 cleanup"; exit 1; }
kubectl create ns reports >/dev/null
kubectl create sa report-bot -n reports >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-bot
  namespace: reports
spec:
  replicas: 1
  selector:
    matchLabels:
      app: report-bot
  template:
    metadata:
      labels:
        app: report-bot
    spec:
      serviceAccountName: report-bot
      containers:
      - name: bot
        image: curlimages/curl:8.11.1
        command:
        - sh
        - -c
        - |
          T=/var/run/secrets/kubernetes.io/serviceaccount/token
          while true; do
            curl -sk -o /dev/null -H "Authorization: Bearer $(cat $T)" https://kubernetes.default.svc/api/v1/namespaces/kube-system/secrets
            sleep 0.2
          done
EOF
echo "Q05 ready: audit logging enabled; something is hammering the API server."
