#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
W=$(worker_node); mkdir -p /root/.cka-lab
kubectl create ns maintenance >/dev/null
cat <<EOF | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: maintenance
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
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values: ["$W"]
      containers:
      - name: web
        image: nginx:1.27
---
apiVersion: v1
kind: Pod
metadata:
  name: database
  namespace: maintenance
  labels:
    app: database
spec:
  nodeName: $W
  containers:
  - name: db
    image: busybox:1.37
    command: ["sh", "-c", "date > /data/created; exec sleep 36000"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    emptyDir: {}
EOF
kubectl wait --for=condition=Ready pod/database -n maintenance --timeout=120s >/dev/null
kubectl get pod database -n maintenance -o jsonpath='{.metadata.uid}' > /root/.cka-lab/mock1-q03-db-uid
kubectl rollout status deploy/web -n maintenance --timeout=120s >/dev/null
echo "Q03 ready: namespace maintenance on node $W."
