#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock1
kubectl create ns production --dry-run=client -o yaml | kubectl apply -f - >/dev/null
cat > /root/mock1/app-frontend.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
  labels:
    app: app-frontend
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "if [ ! -f /etc/app/config.yaml ]; then echo 'ERROR: /etc/app/config.yaml not found'; exit 1; fi; echo 'config loaded:'; cat /etc/app/config.yaml; exec sleep 3600"]
EOF
kubectl apply -f /root/mock1/app-frontend.yaml >/dev/null
echo "Q01 ready: pod production/app-frontend is crash-looping (manifest /root/mock1/app-frontend.yaml)."
