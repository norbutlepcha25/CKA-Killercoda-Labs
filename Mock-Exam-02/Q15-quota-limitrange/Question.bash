# Mock Exam 02 - Question 15 - Namespace Quota and Resource Management  (Workloads & Scheduling | 10 min)
#
# Set up resource governance for namespace batch-jobs.
#
# Tasks
# 1. ResourceQuota batch-quota: total CPU 10 cores and total memory 20Gi
#    (for requests; you may also cap limits at the same values)
# 2. LimitRange batch-limits, per container: minimum 500m CPU / 256Mi memory,
#    maximum 4 CPU / 8Gi memory
# 3. Try to create a pod that requests (and limits) 5 CPU / 2Gi - it must be rejected.
#    Save the error to /root/mock2/q15-rejected.txt
# 4. Verify a pod with requests 1 CPU / 1Gi and limits 2 CPU / 2Gi is accepted
