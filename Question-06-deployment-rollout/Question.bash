# Question 06 - Deployment Rolling Update and Rollback  (Workloads & Scheduling | Easy | 10 min)
#
# Tasks
# 1. Create a namespace called exercise-06
# 2. Create a Deployment named webapp with:
#    - 3 replicas
#    - Image: nginx:1.28
#    - Strategy: RollingUpdate with maxSurge=1, maxUnavailable=0
#    - Record the change cause (annotation kubernetes.io/change-cause)
# 3. Verify all 3 replicas are running
# 4. Update the image to nginx:1.29 and record the change
# 5. Watch the rollout status
# 6. Check rollout history - you should see 2 revisions
# 7. Rollback to the previous version (nginx:1.28)
# 8. Verify the rollback worked by checking the image
