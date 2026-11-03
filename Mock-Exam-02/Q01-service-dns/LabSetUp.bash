#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2
kubectl create ns frontend >/dev/null; kubectl create ns backend >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-ui
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-ui
  template:
    metadata:
      labels:
        app: web-ui
    spec:
      containers:
      - name: web-ui
        image: hashicorp/http-echo:1.0
        args: ["-listen=:3000", "-text=hello from web-ui"]
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: web-ui
  namespace: frontend
spec:
  selector:
    app: web-ui
  ports:
  - port: 3000
    targetPort: 3000
EOF
echo "Q01 ready: Service frontend/web-ui:3000, namespace backend exists."
