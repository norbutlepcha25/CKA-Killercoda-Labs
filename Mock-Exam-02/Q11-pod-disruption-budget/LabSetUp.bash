#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns pdb-demo >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: pdb-demo
spec:
  replicas: 10
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: nginx:1.27
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF
kubectl rollout status deploy/my-app -n pdb-demo --timeout=180s >/dev/null
echo "Q11 ready: Deployment pdb-demo/my-app (10 replicas)."
