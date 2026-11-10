# Mock Exam 03 - Question 08 - Update Kubernetes Version and join cluster  (Cluster Lifecycle | 10%)
#
# A colleague reports that node node01 runs an older Kubernetes version and is not even part
# of the cluster yet.
#
# 1. Update kubelet and kubectl on node01 to the exact version the control plane runs
# 2. Add node01 to the cluster using kubeadm
#
# ssh node01 works from controlplane.
# This question is set up on demand (./mock.sh 3 8) because it removes node01 from the cluster:
# do it near the end of the exam.
