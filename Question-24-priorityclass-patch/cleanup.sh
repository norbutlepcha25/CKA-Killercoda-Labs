#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-24
kubectl delete pod critical-app background-job --ignore-not-found --now >/dev/null 2>&1
kubectl delete priorityclass high-priority --ignore-not-found >/dev/null 2>&1
true
