#!/bin/bash
# Runs ON the worker node. Puts kubelet back on containerd and removes cri-dockerd.
if [ -f /root/.cka-lab/kubeadm-flags.env.bak ] && ! cmp -s /root/.cka-lab/kubeadm-flags.env.bak /var/lib/kubelet/kubeadm-flags.env; then
  systemctl stop kubelet
  command -v docker >/dev/null && docker ps -aq --filter name=k8s_ | xargs -r docker rm -f >/dev/null 2>&1
  cp /root/.cka-lab/kubeadm-flags.env.bak /var/lib/kubelet/kubeadm-flags.env
  systemctl daemon-reload; systemctl start kubelet
fi
systemctl disable --now cri-docker.service cri-docker.socket >/dev/null 2>&1
dpkg -s cri-dockerd >/dev/null 2>&1 && dpkg -r cri-dockerd >/dev/null 2>&1
rm -f /etc/systemd/system/cri-docker.service /etc/systemd/system/cri-docker.socket /usr/local/bin/cri-dockerd
rm -f /etc/sysctl.d/99-kubernetes-cri.conf /etc/sysctl.d/kube.conf
systemctl daemon-reload
true
