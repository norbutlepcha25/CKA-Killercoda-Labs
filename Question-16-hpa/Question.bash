# Question 16 - Horizontal Pod Autoscaler  (Workloads & Scheduling | Medium | 15 min)
#
# The lab setup installed metrics-server.
#
# Tasks
# 1. Create a namespace called exercise-16
# 2. Verify the metrics-server is running in the cluster
# 3. Create a Deployment named load-app with:
#    - Image: registry.k8s.io/hpa-example (or nginx:1.27)
#    - 1 replica
#    - CPU request: 50m
#    - CPU limit: 100m
# 4. Expose it with a ClusterIP Service named load-svc on port 80
# 5. Create an HPA targeting load-app:
#    - Min replicas: 1
#    - Max replicas: 5
#    - Target CPU utilization: 50% (type: Utilization, averageUtilization: 50)
# 6. Verify the HPA YAML has the correct structure (target type is Utilization, not AverageValue)
# 7. Generate load against the service and observe the HPA scaling up
# 8. Stop the load and observe the HPA scaling back down
