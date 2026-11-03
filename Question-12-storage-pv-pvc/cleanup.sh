#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-12
kubectl delete pv my-pv --ignore-not-found >/dev/null 2>&1
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do on_node "$n" "rm -rf /data/exercise-12" >/dev/null 2>&1; done
true
