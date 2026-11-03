#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
kubectl delete cronjob hourly-backup --ignore-not-found >/dev/null 2>&1
kubectl delete job cleanup-job manual-backup --ignore-not-found >/dev/null 2>&1
true
