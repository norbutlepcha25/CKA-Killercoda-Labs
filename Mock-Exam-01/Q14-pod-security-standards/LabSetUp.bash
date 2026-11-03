#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock1
kubectl create ns restricted >/dev/null
echo "Q14 ready: namespace restricted exists (no Pod Security labels yet)."
