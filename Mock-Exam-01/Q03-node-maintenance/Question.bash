# Mock Exam 01 - Question 03 - Node Maintenance  (Cluster Architecture | 6 min)
#
# Node node01 needs maintenance. In namespace maintenance it runs:
#   - Deployment web (3 replicas)
#   - a standalone pod database that keeps its data on node-local storage (emptyDir)
#
# Tasks
# 1. Make sure no new pods are scheduled to node01
# 2. Move the web pods off node01
# 3. The database pod must NOT be evicted or deleted: it must still be the same pod, Running on node01
# 4. Leave node01 in that state (the maintenance itself has not started yet)
#
# Note: while node01 is unschedulable, new pods from other questions only go to the control plane.
