# Question 29 - Troubleshoot Broken Cluster (Incorrect etcd Endpoint)  (Troubleshooting | Hard | 20 min)
#
# The cluster is broken: the API server won't start (kubectl does not work).
#
# Tasks
# 1. Confirm the API server is down
# 2. Check the kube-apiserver container logs (kubectl can't help - use crictl or /var/log/pods)
# 3. Find the error: incorrect etcd endpoint IP or port
# 4. On the control plane node, edit /etc/kubernetes/manifests/kube-apiserver.yaml
# 5. Correct the etcd endpoint in the --etcd-servers= flag
# 6. Verify the IP/port matches the client URLs in /etc/kubernetes/manifests/etcd.yaml
# 7. Save and wait for the API server to restart
# 8. Verify the cluster is healthy: kubectl get nodes, kubectl get pods -A, API server Running
#
# Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
