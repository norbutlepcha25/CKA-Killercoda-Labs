#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns project-swan
kubectl delete clusterrolebinding mock3-secret-reader --ignore-not-found >/dev/null 2>&1
kubectl delete clusterrole mock3-secret-reader --ignore-not-found >/dev/null 2>&1
rm -rf /root/mock3/9
true
