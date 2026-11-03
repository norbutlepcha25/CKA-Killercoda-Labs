#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns crd-demo
kubectl delete crd databases.example.com --ignore-not-found >/dev/null 2>&1
rm -f /root/mock2/q12-*.txt
true
