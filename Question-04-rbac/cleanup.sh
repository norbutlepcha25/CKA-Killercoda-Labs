#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-04
kubectl delete clusterrolebinding dev-node-access --ignore-not-found >/dev/null 2>&1
kubectl delete clusterrole node-viewer --ignore-not-found >/dev/null 2>&1
true
