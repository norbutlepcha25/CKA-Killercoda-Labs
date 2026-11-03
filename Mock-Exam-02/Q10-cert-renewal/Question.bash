# Mock Exam 02 - Question 10 - Cluster Certificate Rotation  (Cluster Architecture | 10 min)
#
# The control plane certificates expire soon. On the control plane node:
#
# Tasks
# 1. Save the current expiration overview (kubeadm) to /root/mock2/q10-before.txt
# 2. Renew all kubeadm-managed certificates
# 3. Make the control plane components use the new certificates - the API server on port 6443
#    must serve the renewed certificate
# 4. Make sure kubectl still works afterwards
