#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
kubectl delete statefulset mysql --ignore-not-found --wait=true >/dev/null 2>&1
kubectl delete svc mysql --ignore-not-found >/dev/null 2>&1
kubectl delete pod debug --ignore-not-found --now >/dev/null 2>&1
for p in $(kubectl get pvc -o name 2>/dev/null | grep '^persistentvolumeclaim/data-mysql-'); do kubectl delete "$p" --wait=false >/dev/null 2>&1; done
true
