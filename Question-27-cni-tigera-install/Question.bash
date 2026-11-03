# Question 27 - CNI Installation (Calico via the Tigera Operator)  (Services & Networking | Hard | 30 min)
#
# The lab setup removed the cluster's CNI. Install Calico v3.30.3 using the Tigera operator.
# Manifests:
#   https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
#   https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/custom-resources.yaml
#
# Tasks
# 1. Find the cluster pod CIDR (kube-controller-manager --cluster-cidr)
# 2. Install the Tigera operator from its manifest and wait for the operator deployment
# 3. Create the Calico Installation custom resource:
#    - Set the IP pool CIDR to match the cluster CIDR
#    - Use VXLAN (or VXLANCrossSubnet) encapsulation
# 4. Wait for the calico-system pods to be Ready and the nodes to become Ready
# 5. Restart pods that were created before the CNI change (e.g. CoreDNS) so they get new IPs
# 6. Verify pods on different nodes can communicate
# 7. Test that NetworkPolicy blocking works
