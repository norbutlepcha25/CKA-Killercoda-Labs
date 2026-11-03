#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
apiserver_reset || exit 1
mkdir -p /root/mock1
kubectl create ns ops >/dev/null
kubectl create sa config-sync -n ops >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-sync
  namespace: ops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: config-sync
  template:
    metadata:
      labels:
        app: config-sync
    spec:
      serviceAccountName: config-sync
      containers:
      - name: sync
        image: curlimages/curl:8.11.1
        command:
        - sh
        - -c
        - |
          T=/var/run/secrets/kubernetes.io/serviceaccount/token
          while true; do
            curl -sk -o /dev/null -H "Authorization: Bearer $(cat $T)" https://kubernetes.default.svc/api/v1/namespaces/default/configmaps
            sleep 5
          done
EOF
echo "Q08 ready: something is reading ConfigMaps in namespace default."
