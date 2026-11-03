#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns shop >/dev/null
mk(){ # name tier port
cat <<EOF | kubectl apply -f - >/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: $1
  namespace: shop
  labels: {$( [ -n "$2" ] && echo "tier: $2" || echo "role: outsider" )}
spec:
  containers:
  - name: app
    image: nginx:1.27
    command: ["sh", "-c", "sed -i 's/80;/$3;/' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
    ports:
    - containerPort: $3
EOF
}
mk frontend frontend 80; mk backend backend 3000; mk database database 5432; mk outsider "" 80
kubectl wait --for=condition=Ready pod --all -n shop --timeout=180s >/dev/null
echo "Q05 ready: namespace shop with pods frontend, backend, database, outsider."
