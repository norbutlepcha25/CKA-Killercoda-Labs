#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns priority-demo
kubectl delete priorityclass critical-workload standard-workload --ignore-not-found >/dev/null 2>&1
rm -f /root/mock2/q07-first-evicted.txt
true
