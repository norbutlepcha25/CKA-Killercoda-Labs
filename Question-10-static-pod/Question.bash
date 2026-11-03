# Question 10 - Static Pod  (Workloads & Scheduling | Easy | 10 min)
#
# Work on the control plane node (controlplane).
#
# Tasks
# 1. Find the static pod manifest directory on the node
# 2. Create a static pod manifest file for a pod named static-web with:
#    - Image: nginx:1.27
#    - Port: 80
# 3. Verify the static pod appears in kubectl get pods (it will have the node name appended)
#    -> run ./lab.sh 10 validate now to check this part
# 4. Try to delete the static pod with kubectl - observe what happens
# 5. Delete the static pod by removing the manifest file
# 6. Verify the pod is gone
#    -> run ./lab.sh 10 validate again
