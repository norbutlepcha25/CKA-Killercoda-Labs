ssh node01
dpkg -i /root/cri-dockerd.deb             # needs docker: apt-get install -y docker.io if it complains
modprobe overlay && modprobe br_netfilter
printf "overlay\nbr_netfilter\n" > /etc/modules-load.d/k8s.conf
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/kube.conf
sysctl --system
systemctl enable --now cri-docker.socket cri-docker.service
systemctl status cri-docker --no-pager
ls -la /run/cri-dockerd.sock

# switch the kubelet (kubeadm stores the runtime flag here):
cat /var/lib/kubelet/kubeadm-flags.env
systemctl stop kubelet
crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmp -fa   # stop old containerd pods (avoid port clashes)
sed -i 's#--container-runtime-endpoint=[^ "]*#--container-runtime-endpoint=unix:///run/cri-dockerd.sock#' /var/lib/kubelet/kubeadm-flags.env
cat /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload && systemctl restart kubelet
exit
kubectl get nodes -o wide                  # node01 Ready, CONTAINER-RUNTIME docker://...
# If pods on node01 get no IP: add --network-plugin=cni to ExecStart in
# /lib/systemd/system/cri-docker.service, then daemon-reload + restart cri-docker.
