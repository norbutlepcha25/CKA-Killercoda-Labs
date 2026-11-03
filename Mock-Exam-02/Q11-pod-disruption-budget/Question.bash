# Mock Exam 02 - Question 11 - Pod Disruption Budgets  (Workloads & Scheduling | 8 min)
#
# Deployment my-app in namespace pdb-demo runs 10 replicas (label app=my-app). It may never lose
# more than 2 pods at once to voluntary disruptions such as node drains.
#
# Tasks
# 1. Create PodDisruptionBudget app-pdb in pdb-demo that enforces this
# 2. Test it: drain node01 (ignore DaemonSets, use --timeout=60s) and watch the evictions get blocked
# 3. Uncordon node01 afterwards and make sure all 10 replicas are available again
