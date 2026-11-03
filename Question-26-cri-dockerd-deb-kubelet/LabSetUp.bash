#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
W=$(worker_node)
on_node "$W" "mkdir -p /root/.cka-lab && [ -f /root/.cka-lab/kubeadm-flags.env.bak ] || cp /var/lib/kubelet/kubeadm-flags.env /root/.cka-lab/kubeadm-flags.env.bak"
echo "Downloading the cri-dockerd package to $W:/root/cri-dockerd.deb ..."
on_node "$W" "wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.20/cri-dockerd_0.3.20.3-0.debian-bullseye_amd64.deb -O /root/cri-dockerd.deb" || { echo "download failed"; exit 1; }
if on_node "$W" "command -v docker" >/dev/null 2>&1; then echo "Docker is installed on $W."; else echo "Docker is NOT installed on $W - install it first (apt-get install -y docker.io)."; fi
echo "Lab ready. Do this exercise on $W (ssh $W). Best done in a fresh Killercoda session."
