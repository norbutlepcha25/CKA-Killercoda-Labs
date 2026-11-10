# Mock Exam 03 - Question 19 - Preview: Kube-Proxy iptables  (Services & Networking | 4%)
#
# Confirm kube-proxy works. In Namespace project-lynx:
# 1. Create Pod p2-pod with image nginx:1-alpine
# 2. Create Service p2-service that exposes the Pod inside the cluster on port 3000 -> 80
# 3. Write the iptables rules of node controlplane that belong to Service p2-service into
#    /root/mock3/19/iptables.txt
# 4. Delete the Service and confirm its iptables rules are gone
