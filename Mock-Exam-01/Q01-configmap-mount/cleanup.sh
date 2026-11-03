#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete pod app-frontend -n production --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
kubectl delete cm app-config -n production --ignore-not-found >/dev/null 2>&1
rm -f /root/mock1/app-frontend.yaml
true
