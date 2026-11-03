#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
kubectl delete pod critical-app background-job --ignore-not-found --now >/dev/null 2>&1
kubectl delete priorityclass high-priority low-priority --ignore-not-found >/dev/null 2>&1
true
