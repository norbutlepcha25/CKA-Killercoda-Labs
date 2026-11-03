#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2
kubectl create ns priority-demo >/dev/null
echo "Q07 ready: namespace priority-demo exists."
