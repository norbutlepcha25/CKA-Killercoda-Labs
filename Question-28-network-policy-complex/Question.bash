# Question 28 - Complex NetworkPolicy (Multi-Namespace)  (Services & Networking | Hard | 25 min)
#
# The lab setup created 3 namespaces with one app each (steps 1-2 are done):
#   frontend : Deployment/Service frontend (nginx, port 80),   pod label tier=frontend
#   backend  : Deployment/Service backend  (HTTP on 8080),     pod label tier=backend
#   database : Deployment/Service database (redis, port 6379), pod label tier=database
#
# Tasks
# 3. Create NetworkPolicies so that:
#    - Everything is denied by default in all three namespaces (ingress AND egress)
#    - frontend -> backend is allowed, only on TCP 8080
#    - backend -> database is allowed, only on TCP 6379
#    - DNS (UDP/TCP 53 to kube-dns in kube-system) is allowed for all pods
# 4. Explicitly test connectivity to confirm the policies are enforced:
#    - frontend CAN reach backend on 8080
#    - frontend CANNOT reach database
#    - backend CAN reach database on 6379
#    - backend CANNOT reach frontend
#    - a pod in the default namespace CANNOT reach backend
# 5. Verify DNS still works from all namespaces
# 6. If policies don't enforce, verify the CNI supports NetworkPolicy
