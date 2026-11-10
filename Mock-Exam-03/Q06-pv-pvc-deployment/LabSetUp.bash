#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-t230 >/dev/null
echo "Q06 ready: namespace project-t230"
DEF=$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null)
[ -n "$DEF" ] && echo "Note: this cluster has a default StorageClass ($DEF) - see the hint in the question."
true
