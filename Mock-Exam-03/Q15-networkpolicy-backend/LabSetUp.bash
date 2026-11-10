#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=project-snake; kubectl create ns $NS >/dev/null
pod(){ # name app text listen-lines
  cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: $1-conf
  namespace: $NS
data:
  default.conf: |
    server {
      $4
      default_type text/plain;
      location / { return 200 '$3'; }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: $1
  namespace: $NS
  labels:
    app: $2
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
    volumeMounts:
    - name: conf
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: conf
    configMap:
      name: $1-conf
YAML
}
pod backend-0 backend "backend" "listen 80;"
pod db1-0 db1 "database one" "listen 1111; listen 2222;"
pod db2-0 db2 "database two" "listen 1111; listen 2222;"
pod vault-0 vault "vault secret storage" "listen 3333;"
wait_ready $NS app 180s
echo "Q15 ready: namespace project-snake"
