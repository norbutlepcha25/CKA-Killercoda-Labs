#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
DSC=$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}')
if [ -n "$DSC" ]; then echo "Default StorageClass: $DSC (volumeClaimTemplates will use it)"
else echo "WARNING: no default StorageClass found - add storageClassName to your volumeClaimTemplates."; fi
echo "Lab ready. Work in the default namespace."
