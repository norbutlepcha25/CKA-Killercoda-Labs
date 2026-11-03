# Mock Exam 02 - Question 02 - Deployment Rolling Update and Rollback  (Workloads | 8 min)
#
# Deployment payment-service in namespace payments was updated to a version that does not work.
#
# Tasks
# 1. Check the rollout history of payment-service
# 2. Write the number of the broken revision to /root/mock2/q02-bad-revision.txt
# 3. Roll back to the last working version (image nginx:1.27)
# 4. Verify the rollback completed and all 3 replicas are available
