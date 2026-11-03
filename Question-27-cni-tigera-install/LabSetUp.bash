#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
if kubectl get installation default >/dev/null 2>&1 || kubectl get ns tigera-operator >/dev/null 2>&1; then
  echo "The Tigera operator is already installed here. Start a fresh Killercoda session to practise this lab."; exit 1
fi
echo "WARNING: this lab REMOVES the cluster's current CNI so you can install Calico yourself."
echo "Pod networking will be down until you finish. Use a fresh Killercoda session and do this lab on its own."
if [ "$CKA_LAB_YES" != 1 ]; then read -r -p "Type yes to continue: " a; [ "$a" = yes ] || { echo "Aborted."; exit 1; }; fi
for ds in $(kubectl get ds -n kube-system -o name | grep -E 'canal|flannel|calico|cilium|weave'); do kubectl delete -n kube-system "$ds" --wait=true; done
kubectl delete deploy calico-kube-controllers -n kube-system --ignore-not-found
kubectl delete ns kube-flannel --ignore-not-found
for c in $(kubectl get crd -o name | grep 'projectcalico.org'); do kubectl delete "$c" --wait=false >/dev/null; done
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  on_node "$n" "rm -f /etc/cni/net.d/*canal* /etc/cni/net.d/*flannel* /etc/cni/net.d/*calico* /etc/cni/net.d/*cilium* /etc/cni/net.d/*weave*; ip link delete flannel.1 2>/dev/null; ip link delete cni0 2>/dev/null; ip link delete vxlan.calico 2>/dev/null; true"
done
echo "Lab ready. The CNI has been removed - nodes will turn NotReady shortly."
