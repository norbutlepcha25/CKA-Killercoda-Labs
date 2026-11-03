#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_ingress_nginx
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: hashicorp/http-echo:1.0
        args: ["-listen=:5678", "-text=api says hello"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: default
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 5678
EOF
D=$(mktemp -d)
openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=api.example.com" \
  -addext "subjectAltName=DNS:api.example.com" -keyout $D/tls.key -out $D/tls.crt >/dev/null 2>&1
kubectl create secret tls api-tls-cert -n default --cert=$D/tls.crt --key=$D/tls.key >/dev/null
rm -rf $D
kubectl rollout status deploy/api --timeout=120s >/dev/null
echo "Q10 ready: Service default/api, secret default/api-tls-cert, IngressClass nginx."
kubectl get svc -n ingress-nginx ingress-nginx-controller
