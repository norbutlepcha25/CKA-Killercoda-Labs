#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns staging >/dev/null
kubectl create deployment api -n staging --image=nginx:1.27 >/dev/null
echo "Q02 ready: namespace staging exists."
