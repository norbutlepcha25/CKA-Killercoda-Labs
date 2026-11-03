#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
for ns in frontend backend database; do kubectl create ns $ns >/dev/null; done
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata: {name: frontend, namespace: frontend}
spec:
  selector: {matchLabels: {tier: frontend}}
  template:
    metadata: {labels: {tier: frontend}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata: {name: frontend, namespace: frontend}
spec:
  selector: {tier: frontend}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: backend, namespace: backend}
spec:
  selector: {matchLabels: {tier: backend}}
  template:
    metadata: {labels: {tier: backend}}
    spec:
      containers:
      - name: api
        image: busybox:1.36
        command: ["sh", "-c", "mkdir -p /www && echo backend-ok > /www/index.html && httpd -f -p 8080 -h /www"]
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: backend, namespace: backend}
spec:
  selector: {tier: backend}
  ports: [{port: 8080, targetPort: 8080}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: database, namespace: database}
spec:
  selector: {matchLabels: {tier: database}}
  template:
    metadata: {labels: {tier: database}}
    spec:
      containers:
      - name: redis
        image: redis:7
        ports: [{containerPort: 6379}]
---
apiVersion: v1
kind: Service
metadata: {name: database, namespace: database}
spec:
  selector: {tier: database}
  ports: [{port: 6379, targetPort: 6379}]
EOF
for ns in frontend backend database; do kubectl rollout status deploy/$ns -n $ns --timeout=180s >/dev/null; done
kubectl get deploy,svc -n frontend; kubectl get deploy,svc -n backend; kubectl get deploy,svc -n database
echo "Lab ready. Apps are deployed in frontend, backend and database - no NetworkPolicies yet."
