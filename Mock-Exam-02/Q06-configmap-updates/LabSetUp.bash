#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/.cka-lab
kubectl create ns config-demo >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: config-demo
data:
  mode: blue
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: volume-app
  namespace: config-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: volume-app
  template:
    metadata:
      labels:
        app: volume-app
    spec:
      containers:
      - name: app
        image: busybox:1.37
        command: ["sh", "-c", "while true; do echo mode=$(cat /config/mode); sleep 10; done"]
        volumeMounts:
        - name: config
          mountPath: /config
      volumes:
      - name: config
        configMap:
          name: app-config
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: env-app
  namespace: config-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: env-app
  template:
    metadata:
      labels:
        app: env-app
    spec:
      containers:
      - name: app
        image: busybox:1.37
        command: ["sh", "-c", "while true; do echo mode=$MODE; sleep 10; done"]
        env:
        - name: MODE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: mode
EOF
kubectl rollout status deploy/volume-app -n config-demo --timeout=120s >/dev/null
kubectl rollout status deploy/env-app -n config-demo --timeout=120s >/dev/null
kubectl get pod -n config-demo -l app=volume-app -o jsonpath='{.items[0].metadata.uid}' > /root/.cka-lab/mock2-q06-uid
echo "Q06 ready: namespace config-demo."
