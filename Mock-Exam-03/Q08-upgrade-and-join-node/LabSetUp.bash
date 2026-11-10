#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/.cka-lab
CP=$(cp_node); W=$(worker_node)
if [ -z "$W" ] || [ "$W" = "$CP" ] || ! kubectl get node "$W" >/dev/null 2>&1; then echo "No worker node found."; exit 1; fi
CPV=$(jp '{.status.nodeInfo.kubeletVersion}' node "$CP")        # e.g. v1.34.1
MIN=$(echo "$CPV" | cut -d. -f2); PREV="1.$((MIN - 1))"
echo "$W" > /root/.cka-lab/mock3-q8-node
echo "Removing $W from the cluster (pods move to $CP) ..."
kubectl drain "$W" --ignore-daemonsets --delete-emptydir-data --force --timeout=120s >/dev/null 2>&1
kubectl delete node "$W" >/dev/null
on_node "$W" "kubeadm reset -f >/dev/null 2>&1; systemctl stop kubelet"
echo "Installing kubelet/kubectl $PREV.x on $W ..."
on_node "$W" "
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v$PREV/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-mock3-prev.gpg &&
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-mock3-prev.gpg] https://pkgs.k8s.io/core:/stable:/v$PREV/deb/ /' > /etc/apt/sources.list.d/kubernetes-mock3-prev.list &&
  apt-get update -qq >/dev/null 2>&1
  P=\$(apt-cache madison kubelet | awk '{print \$3}' | grep '^$PREV\.' | sort -V | tail -1)
  [ -n \"\$P\" ] || exit 1
  apt-mark unhold kubelet kubectl >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --allow-downgrades --allow-change-held-packages kubelet=\$P kubectl=\$P >/dev/null 2>&1
  apt-mark hold kubelet kubectl >/dev/null 2>&1
  systemctl restart kubelet >/dev/null 2>&1; true" \
  || echo "  (could not install an older kubelet - $W keeps its current version; joining is still required)"
echo "Q08 ready: $W is no longer part of the cluster. Control plane runs $CPV."
echo "Do this question near the end: until $W rejoins, all pods run on $CP."
