# Question 24 - PriorityClass and Patch Operations  (Workloads & Scheduling | Medium | 15 min)
#
# Tasks
# 1. Create a namespace called exercise-24
# 2. Create a PriorityClass with:
#    - Name: high-priority
#    - Value: 999999
#    - Description: "Critical workload"
# 3. Create a Deployment named critical-app in exercise-24:
#    - 1 replica, image busybox:1.36, command sleep 3600
#    - Do NOT specify priorityClassName yet
# 4. Use kubectl patch to add priorityClassName: high-priority to the Deployment
# 5. Verify the pod has the priority class assigned
# 6. Create a second, lower-priority Deployment named normal-app (busybox:1.36, sleep 3600, no priority class)
# 7. Compare the .spec.priority of both pods
