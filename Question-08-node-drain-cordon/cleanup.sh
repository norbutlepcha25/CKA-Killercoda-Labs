#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node)
kubectl uncordon "$W" >/dev/null 2>&1
kubectl delete deployment drain-test --ignore-not-found --wait=true >/dev/null 2>&1
true
