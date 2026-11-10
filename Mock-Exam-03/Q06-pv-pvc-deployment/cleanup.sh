#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns project-t230
kubectl delete pv safari-pv --ignore-not-found >/dev/null 2>&1
true
