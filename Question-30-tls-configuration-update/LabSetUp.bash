#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-30 >/dev/null
T=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $T/tls.key -out $T/tls.crt -subj "/CN=tls-web.exercise-30" >/dev/null 2>&1
kubectl -n exercise-30 create secret tls tls-web-cert --cert=$T/tls.crt --key=$T/tls.key >/dev/null
rm -rf $T
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: tls-config
  namespace: exercise-30
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        ssl_certificate     /etc/nginx/tls/tls.crt;
        ssl_certificate_key /etc/nginx/tls/tls.key;
        ssl_protocols TLSv1.3;
        location / {
          return 200 "Hello TLS\n";
        }
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tls-web
  namespace: exercise-30
spec:
  replicas: 1
  selector:
    matchLabels: {app: tls-web}
  template:
    metadata:
      labels: {app: tls-web}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 443}]
        volumeMounts:
        - {name: config, mountPath: /etc/nginx/nginx.conf, subPath: nginx.conf}
        - {name: tls, mountPath: /etc/nginx/tls}
      volumes:
      - {name: config, configMap: {name: tls-config}}
      - {name: tls, secret: {secretName: tls-web-cert}}
---
apiVersion: v1
kind: Service
metadata:
  name: tls-web
  namespace: exercise-30
spec:
  selector: {app: tls-web}
  ports: [{port: 443, targetPort: 443}]
EOF
kubectl rollout status deploy/tls-web -n exercise-30 --timeout=120s >/dev/null
echo "Lab ready. Service exercise-30/tls-web (ClusterIP $(kubectl get svc tls-web -n exercise-30 -o jsonpath='{.spec.clusterIP}'), port 443) only accepts TLS 1.3."
