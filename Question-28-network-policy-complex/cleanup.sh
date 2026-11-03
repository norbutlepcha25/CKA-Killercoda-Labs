#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns frontend backend database
kubectl delete pod np-outsider --ignore-not-found --now >/dev/null 2>&1
true
