# Question 11 - Troubleshoot Cluster Components  (Troubleshooting | Hard | 25 min)
#
# The lab setup has broken the cluster. Find and fix every problem.
#
# Scenario A: Broken kubelet
# 1. A worker node is NotReady. Identify which node and why
# 2. SSH to it and check the kubelet service status and logs
# 3. Fix it so the node is Ready - and stays fixed after a reboot
#
# Scenario B: CoreDNS troubleshooting
# 1. Create a pod and try to resolve a service name (kubernetes.default) - it fails
# 2. Check the CoreDNS pods in kube-system
# 3. Check that the kube-dns service has endpoints
# 4. Check the CoreDNS logs for errors
# 5. Verify the CoreDNS ConfigMap for misconfigurations
# 6. Fix all issues and verify DNS resolution works
#
# Scenario C: kube-proxy (investigate only)
# 1. Check if kube-proxy pods are running on all nodes
# 2. Check kube-proxy logs
# 3. Verify the kube-proxy ConfigMap
# 4. Check iptables rules on a node
#
# Scenario D: API server audit logs (investigate only)
# 1. Check the kube-apiserver manifest for audit flags (--audit-policy-file, --audit-log-path)
# 2. Killercoda does not enable audit logging by default - note which flags and volume
#    mounts you would add to enable it, and where the log file would be written
