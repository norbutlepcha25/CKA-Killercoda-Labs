#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-lynx >/dev/null
mkdir -p /root/mock3/19
MODE=$(kubectl -n kube-system get cm kube-proxy -o jsonpath='{.data.config\.conf}' 2>/dev/null | sed -n 's/^mode: *//p' | tr -d '"')
echo "Q19 ready: namespace project-lynx (kube-proxy mode: ${MODE:-iptables (default)})"
