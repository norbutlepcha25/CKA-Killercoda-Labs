#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2
kubectl create ns batch-jobs >/dev/null
echo "Q15 ready: namespace batch-jobs exists."
