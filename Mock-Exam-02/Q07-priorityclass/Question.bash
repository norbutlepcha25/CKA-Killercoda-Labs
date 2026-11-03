# Mock Exam 02 - Question 07 - PriorityClass and Eviction Order  (Workloads & Scheduling | 9 min)
#
# Tasks
# 1. Create PriorityClass critical-workload with value 1000 and PriorityClass standard-workload
#    with value 100. Both use preemptionPolicy PreemptLowerPriority. Neither is the global default.
# 2. In namespace priority-demo create pods critical-pod-1 and critical-pod-2 (priority class
#    critical-workload) and standard-pod (priority class standard-workload), all image nginx:1.27
# 3. If the node runs out of memory and all three pods use more memory than they request, which
#    pod does the kubelet evict first? Write its name to /root/mock2/q07-first-evicted.txt
