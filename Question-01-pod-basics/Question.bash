# Question 01 - Pod Basics  (Workloads & Scheduling | Easy | 10 min)
#
# Create a pod with specific resource requests, labels, and verify it's running.
#
# Tasks
# 1. Create a namespace called exercise-01
# 2. Create a pod named web in namespace exercise-01 with:
#    - Image: nginx:1.27
#    - Labels: app=web, tier=frontend
#    - Resource requests: 64Mi memory, 100m CPU
#    - Resource limits: 128Mi memory, 250m CPU
# 3. Verify the pod is running and has the correct labels
# 4. Get the pod's IP address using -o wide
# 5. Add a new label version=v1 to the running pod
# 6. Remove the tier label from the pod
