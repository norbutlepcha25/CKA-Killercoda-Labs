# Mock Exam 02 - Question 08 - Service Types and Exposure  (Services & Networking | 7 min)
#
# Deployment legacy-app in namespace legacy (pod label app=legacy) listens on port 3000.
# It must be reachable from outside the cluster without an Ingress.
#
# Tasks
# 1. Create Service legacy-app of type NodePort in namespace legacy:
#    service port 8080 -> targetPort 3000, nodePort 30080
# 2. Verify it answers on <node-ip>:30080 from outside the pod network
#
# (The original task asked for node port 8080. NodePorts must be inside the node port range,
#  30000-32767 by default, so 8080 is the service port here.)
