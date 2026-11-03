#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-25
kubectl delete pv local-pv-1 --ignore-not-found >/dev/null 2>&1
kubectl delete storageclass local-storage --ignore-not-found >/dev/null 2>&1
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do on_node "$n" "rm -rf /tmp/k8s-pv" >/dev/null 2>&1; done
true
