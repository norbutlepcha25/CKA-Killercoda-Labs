#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
CP=$(cp_node); mkdir -p /root/.cka-lab
if ! kubectl get node "$CP" -o jsonpath='{range .spec.taints[*]}{.key}:{.effect}{"\n"}{end}' | grep -q '^node-role.kubernetes.io/control-plane:NoSchedule$'; then
  kubectl taint node "$CP" node-role.kubernetes.io/control-plane:NoSchedule >/dev/null
  touch /root/.cka-lab/mock2-q04-added-taint
  echo "Note: added the standard kubeadm taint node-role.kubernetes.io/control-plane:NoSchedule to $CP (cleanup removes it)."
fi
kubectl create ns monitoring >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-agent
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    metadata:
      labels:
        app: monitoring-agent
    spec:
      containers:
      - name: agent
        image: busybox:1.37
        command: ["sh", "-c", "while true; do echo collecting metrics on $NODE; sleep 60; done"]
        env:
        - name: NODE
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF
echo "Q04 ready: DaemonSet monitoring/monitoring-agent."
