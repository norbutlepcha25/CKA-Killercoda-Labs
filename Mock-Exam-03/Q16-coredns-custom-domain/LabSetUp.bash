#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/.cka-lab /root/mock3/16
kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > /root/.cka-lab/mock3-coredns.Corefile
echo "Q16 ready (original Corefile saved to /root/.cka-lab/mock3-coredns.Corefile for cleanup)."
