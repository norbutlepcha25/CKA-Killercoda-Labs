# Question 08 - Node Drain and Cordon  (Cluster Architecture | Easy | 10 min)
#
# Work in the default namespace. The worker node on Killercoda is node01.
#
# Tasks
# 1. List all nodes and identify a worker node
# 2. Cordon the worker node (mark it unschedulable)
# 3. Verify the node shows SchedulingDisabled
# 4. Create a Deployment named drain-test (image nginx:1.27, 3 replicas) and observe where pods are scheduled
# 5. Drain the worker node - handle DaemonSets and local data
# 6. Verify all non-DaemonSet pods have been evicted from the node
# 7. Uncordon the node
# 8. Scale the deployment to 6 replicas and verify pods get scheduled on the uncordoned node
