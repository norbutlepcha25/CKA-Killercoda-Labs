#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete pod app-with-logger -n default --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
true
