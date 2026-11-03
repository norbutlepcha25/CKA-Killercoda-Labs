#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns databases
kubectl delete pv db-pv --ignore-not-found >/dev/null 2>&1
kubectl delete sc fast-ssd --ignore-not-found >/dev/null 2>&1
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do on_node "$n" "rm -rf /mnt/fast-ssd" >/dev/null 2>&1; done
true
