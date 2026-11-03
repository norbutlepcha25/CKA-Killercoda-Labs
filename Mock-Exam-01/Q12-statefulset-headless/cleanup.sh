#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete sts database-cluster -n default --ignore-not-found --wait=false >/dev/null 2>&1
kubectl delete svc database-cluster -n default --ignore-not-found >/dev/null 2>&1
kubectl delete pod -n default -l app=database-cluster --force --grace-period=0 >/dev/null 2>&1
for p in $(kubectl get pvc -n default -o name 2>/dev/null | grep database-cluster); do kubectl delete -n default "$p" --wait=false >/dev/null 2>&1; done
true
