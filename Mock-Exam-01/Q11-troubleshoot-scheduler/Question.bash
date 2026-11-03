# Mock Exam 01 - Question 11 - Cluster Troubleshooting  (Troubleshooting | 12 min)
#
# The kube-scheduler has stopped running. Pod sched-test in namespace default stays Pending.
#
# Tasks
# 1. Check the status of the control plane components
# 2. Find out why the kube-scheduler is not running (static pod - kubelet / container logs)
# 3. Fix it so the scheduler runs again and sched-test gets scheduled
# 4. Document the root cause in one line in /root/mock1/q11-cause.txt
#
# Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
# (./mock.sh 1 start does not break the scheduler - run ./mock.sh 1 11 when you reach this question.)
