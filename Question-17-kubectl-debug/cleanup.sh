#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-17
for p in $(kubectl get pods -A --no-headers 2>/dev/null | awk '$2 ~ /^node-debugger-/ {print $1"/"$2}'); do
  kubectl delete pod -n "${p%/*}" "${p#*/}" --now >/dev/null 2>&1
done
true
