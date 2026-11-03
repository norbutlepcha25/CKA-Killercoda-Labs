#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
W=$(worker_node)
echo "Preparing $W: installing docker + cri-dockerd (takes 1-2 minutes) ..."
on_node "$W" "mkdir -p /root/.cka-lab && { [ -f /root/.cka-lab/kubeadm-flags.env.bak ] || cp /var/lib/kubelet/kubeadm-flags.env /root/.cka-lab/kubeadm-flags.env.bak; }"
on_node "$W" "command -v docker >/dev/null || { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker.io; } >/dev/null 2>&1" || { echo "docker install failed"; exit 1; }
on_node "$W" "wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.20/cri-dockerd_0.3.20.3-0.debian-bullseye_amd64.deb -O /root/cri-dockerd.deb && dpkg -i /root/cri-dockerd.deb >/dev/null 2>&1" || { echo "cri-dockerd install failed"; exit 1; }
on_node "$W" "grep -q 'network-plugin=cni' /lib/systemd/system/cri-docker.service || sed -i 's#^ExecStart=\(.*\)#ExecStart=\1 --network-plugin=cni#' /lib/systemd/system/cri-docker.service; systemctl daemon-reload; systemctl enable --now cri-docker.socket cri-docker.service >/dev/null 2>&1"
on_node "$W" "systemctl is-active cri-docker.service; ls -la /run/cri-dockerd.sock"
echo "Q07 ready: docker + cri-dockerd running on $W; kubelet still uses containerd."
