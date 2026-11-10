#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
F=/root/.cka-lab/mock3-q8-node
[ -f $F ] || exit 0
W=$(cat $F); CP=$(cp_node)
CPV=$(jp '{.status.nodeInfo.kubeletVersion}' node "$CP"); V=${CPV#v}
if ! kubectl get node "$W" >/dev/null 2>&1; then
  echo "Re-joining $W to the cluster on $CPV ..."
  J=$(kubeadm token create --print-join-command 2>/dev/null)
  on_node "$W" "
    rm -f /etc/apt/sources.list.d/kubernetes-mock3-prev.list; apt-get update -qq >/dev/null 2>&1
    P=\$(apt-cache madison kubelet | awk '{print \$3}' | grep '^$V-' | head -1)
    apt-mark unhold kubelet kubectl kubeadm >/dev/null 2>&1
    [ -n \"\$P\" ] && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --allow-downgrades --allow-change-held-packages kubelet=\$P kubectl=\$P kubeadm=\$P >/dev/null 2>&1
    apt-mark hold kubelet kubectl kubeadm >/dev/null 2>&1
    kubeadm reset -f >/dev/null 2>&1; $J >/dev/null 2>&1" || echo "  join failed - run kubeadm join on $W by hand"
  kubectl wait --for=condition=Ready node/"$W" --timeout=180s >/dev/null 2>&1
fi
on_node "$W" "rm -f /etc/apt/sources.list.d/kubernetes-mock3-prev.list /etc/apt/keyrings/kubernetes-mock3-prev.gpg" >/dev/null 2>&1
kubectl uncordon "$W" >/dev/null 2>&1
rm -f $F
true
