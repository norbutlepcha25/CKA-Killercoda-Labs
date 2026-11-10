kubectl get node                                    # control plane version, e.g. v1.34.1
ssh node01
kubelet --version; kubectl version --client; kubeadm version -o short
kubeadm upgrade node                                # fails: node is not part of a cluster -> nothing to upgrade
apt-get update
apt-cache madison kubelet | grep 1.34.1              # use the control plane version
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.34.1-1.1 kubectl=1.34.1-1.1   # (and kubeadm too if it is not on that version)
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet # crash-loops until the node is joined - expected
exit
# on controlplane: create a token and print the join command
kubeadm token create --print-join-command
ssh node01 "kubeadm join <...printed command...>"    # run kubeadm reset -f first if the join complains
kubectl get node                                     # node01 Ready, same version
