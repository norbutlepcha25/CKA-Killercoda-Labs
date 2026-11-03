#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns databases >/dev/null
kubectl create deployment db-app -n databases --image=nginx:1.27 >/dev/null
echo "Q04 ready: Deployment databases/db-app exists."
