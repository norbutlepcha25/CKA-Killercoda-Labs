# Question 09 - kubeadm Cluster Upgrade  (Cluster Architecture | Hard | 25 min)
#
# The lab setup prepared the apt repository on both nodes.
# Target version:  cat /root/upgrade-target.txt          (e.g. v1.36.0)
# Apt package:     cat /root/upgrade-target-package.txt  (e.g. 1.36.0-1.1)
#
# Tasks
# 1. Check the current cluster version (kubectl get nodes, kubeadm version)
# 2. Upgrade the control plane node (controlplane) to the target version:
#    a. Update the kubeadm package to the target version
#    b. Run kubeadm upgrade plan to see available upgrades
#    c. Run kubeadm upgrade apply <target version>
#    d. Upgrade the kubelet and kubectl packages
#    e. Restart kubelet
# 3. Upgrade the worker node (node01):
#    a. Drain the worker node
#    b. Update the kubeadm, kubelet, kubectl packages on the worker
#    c. Run kubeadm upgrade node
#    d. Restart kubelet
#    e. Uncordon the worker
# 4. Verify all nodes show the new version
#
# Note: an upgrade cannot be undone. Start a fresh Killercoda session to practise it again.
