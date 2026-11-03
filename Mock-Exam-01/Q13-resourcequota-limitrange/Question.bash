# Mock Exam 01 - Question 13 - Resource Quotas and Limits  (Workloads & Scheduling | 8 min)
#
# Namespace test uses too many resources.
#
# Tasks
# 1. Create ResourceQuota test-quota in namespace test: total CPU requests 4 cores and total
#    memory requests 8Gi (you may also cap limits at the same values)
# 2. Create LimitRange test-limits in namespace test so every container must request at least
#    100m CPU and 128Mi memory
# 3. Verify that a pod requesting 6 CPUs / 4Gi (limits equal) is rejected, and so is a pod
#    requesting 50m CPU / 64Mi. Save the error for the 6-CPU pod to /root/mock1/q13-rejected.txt
