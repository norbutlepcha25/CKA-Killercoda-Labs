#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node)
mkdir -p /root/.cka-lab
# Save the healthy state the first time only, so cleanup can restore it
if [ ! -f /root/.cka-lab/coredns-Corefile.bak ]; then
  kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > /root/.cka-lab/coredns-Corefile.bak
  kubectl -n kube-system get deploy coredns -o jsonpath='{.spec.replicas}' > /root/.cka-lab/coredns-replicas
fi
bash "$HERE/cleanup.sh"
sleep 5
echo "Breaking the cluster ..."
# Break 1: kubelet on the worker
on_node "$W" "systemctl disable --now kubelet" >/dev/null 2>&1
# Break 2: CoreDNS - typo in the Corefile and zero replicas
kubectl -n kube-system get cm coredns -o yaml | sed 's/kubernetes cluster\.local/kubernetess cluster.local/' | kubectl replace -f - >/dev/null
kubectl -n kube-system scale deploy coredns --replicas=0 >/dev/null
echo "Lab ready. Something is wrong with the cluster - see the question."
