# Question 22 - PriorityClass  (Workloads & Scheduling | Medium | 15 min)
#
# Work in the default namespace.
#
# Tasks
# 1. Create a PriorityClass named high-priority with value 1000 and preemptionPolicy PreemptLowerPriority
# 2. Create a PriorityClass named low-priority with value 10 and preemptionPolicy Never
# 3. Create a Pod named critical-app using nginx:1.28 and assign it to the high-priority class
# 4. Create a Pod named background-job using busybox:1.37 running sleep 3600 and assign it to the low-priority class
# 5. Verify both pods are running. Check their priority values (priority and priorityClassName)
# 6. Optional: drain a node to trigger preemption and observe which pod gets evicted
