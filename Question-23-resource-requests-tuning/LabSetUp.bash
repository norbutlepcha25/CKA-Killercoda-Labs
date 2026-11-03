#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
# Work out a CPU request that is too big: 60% of the largest node's allocatable CPU
MAX=0
for c in $(kubectl get nodes -o jsonpath='{.items[*].status.allocatable.cpu}'); do
  case "$c" in *m) m=${c%m} ;; *) m=$((c*1000)) ;; esac
  [ "$m" -gt "$MAX" ] && MAX=$m
done
REQ=$(( MAX * 60 / 100 ))m
kubectl create ns exercise-23 >/dev/null
cat <<EOF | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: exercise-23
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        resources:
          requests:
            cpu: "$REQ"
            memory: "512Mi"
EOF
echo "Lab ready. Deployment exercise-23/web was created with requests cpu=$REQ memory=512Mi (too high on purpose)."
