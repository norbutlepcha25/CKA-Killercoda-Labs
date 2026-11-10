# Mock Exam 03 - Question 14 - Check how long certificates are valid  (Cluster Lifecycle | 2%)
#
# 1. Use openssl (or cfssl) to find out how long the kube-apiserver server certificate is valid.
#    Write its expiration date into /root/mock3/14/expiration.
#    Then use kubeadm to list the expiration dates and confirm both show the same date.
# 2. Write the kubeadm command that would renew the kube-apiserver server certificate into
#    /root/mock3/14/kubeadm-renew-certs.sh  (do not run it)
