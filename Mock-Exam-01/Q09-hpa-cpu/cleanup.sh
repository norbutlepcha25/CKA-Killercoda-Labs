#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete hpa web-app -n production --ignore-not-found >/dev/null 2>&1
kubectl delete deploy web-app -n production --ignore-not-found >/dev/null 2>&1
true
