#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
W=$(worker_node)
kubectl delete pod runtime-check --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
on_node "$W" "bash -s" < "$HERE/../../lib/cri-reset.sh" >/dev/null 2>&1
on_node "$W" "rm -f /root/cri-dockerd.deb" >/dev/null 2>&1
true
