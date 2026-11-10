#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-h800 >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: Service
metadata:
  name: o3db
  namespace: project-h800
spec:
  clusterIP: None
  selector:
    app: o3db
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: o3db
  namespace: project-h800
spec:
  serviceName: o3db
  replicas: 2
  selector:
    matchLabels:
      app: o3db
  template:
    metadata:
      labels:
        app: o3db
    spec:
      containers:
      - name: db
        image: nginx:1-alpine
YAML
kubectl create deployment h800-api -n project-h800 --image=nginx:1-alpine --replicas=2 >/dev/null
kubectl -n project-h800 rollout status sts/o3db --timeout=180s >/dev/null
echo "Q03 ready: namespace project-h800"
