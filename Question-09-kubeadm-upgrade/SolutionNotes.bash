VER=$(cat /root/upgrade-target.txt); PKG=$(cat /root/upgrade-target-package.txt)

# === CONTROL PLANE (controlplane) ===
kubectl drain controlplane --ignore-daemonsets          # optional but recommended
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=$PKG
apt-mark hold kubeadm
kubeadm version
kubeadm upgrade plan
kubeadm upgrade apply $VER -y
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=$PKG kubectl=$PKG
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon controlplane
kubectl get nodes

# === WORKER (node01) ===
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
ssh node01
  PKG=<paste the package version>
  apt-mark unhold kubeadm kubelet kubectl
  apt-get update && apt-get install -y kubeadm=$PKG kubelet=$PKG kubectl=$PKG
  apt-mark hold kubeadm kubelet kubectl
  kubeadm upgrade node
  systemctl daemon-reload && systemctl restart kubelet
  exit
kubectl uncordon node01
kubectl get nodes          # both nodes on the new version

# Remember: control plane = kubeadm upgrade apply, worker = kubeadm upgrade node
