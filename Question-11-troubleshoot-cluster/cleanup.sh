#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
# Restore everything the lab broke
W=$(worker_node)
on_node "$W" "systemctl enable --now kubelet" >/dev/null 2>&1
if [ -f /root/.cka-lab/coredns-Corefile.bak ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile=/root/.cka-lab/coredns-Corefile.bak --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1
fi
R=$(cat /root/.cka-lab/coredns-replicas 2>/dev/null); R=${R:-2}
kubectl -n kube-system scale deploy coredns --replicas="$R" >/dev/null 2>&1
kubectl -n kube-system rollout restart deploy coredns >/dev/null 2>&1
kubectl delete pod test-dns --ignore-not-found --now >/dev/null 2>&1
true
