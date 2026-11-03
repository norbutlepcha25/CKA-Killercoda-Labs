#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns storage-demo
kubectl delete sc ssd --ignore-not-found >/dev/null 2>&1
true
