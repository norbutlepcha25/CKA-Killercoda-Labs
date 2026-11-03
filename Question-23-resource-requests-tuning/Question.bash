# Question 23 - Resource Requests Tuning (Pods Won't Schedule)  (Workloads & Scheduling | Hard | 20 min)
#
# The lab setup created namespace exercise-23 and a Deployment named web (3 replicas, nginx:1.27)
# whose resource requests are intentionally too high for the cluster.
#
# Tasks
# 1. Observe pods Pending - they won't all schedule
# 2. Find out why (describe a Pending pod)
# 3. Check node capacity and available resources (allocatable minus what is already requested)
# 4. Calculate correct resource requests so 3 replicas fit, leaving headroom
# 5. Update the Deployment with the new (lower) requests - keep both cpu and memory requests set
# 6. Verify all 3 pods schedule and run
# 7. Document the calculation in /root/exercise-23-calculation.txt
