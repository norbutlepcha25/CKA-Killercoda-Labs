# Question 04 - RBAC  (Cluster Architecture | Medium | 15 min)
#
# Tasks
# 1. Create a namespace called exercise-04
# 2. Create a ServiceAccount named dev-sa in namespace exercise-04
# 3. Create a Role named pod-manager in namespace exercise-04 that allows:
#    - get, list, watch, create, delete on pods
#    - get, list on services
# 4. Create a RoleBinding named dev-pod-access that binds pod-manager to dev-sa
# 5. Verify that dev-sa can list pods in exercise-04
# 6. Verify that dev-sa cannot list pods in the default namespace
# 7. Create a ClusterRole named node-viewer that allows get, list on nodes
# 8. Create a ClusterRoleBinding named dev-node-access binding node-viewer to dev-sa
# 9. Verify that dev-sa can now list nodes
#
# Additional real-exam scenarios
# 10. A developer reports they cannot delete a deployment in exercise-04. Use kubectl auth can-i to debug why
# 11. Test what dev-sa can do with deployments (should return "no")
# 12. List all permissions granted to dev-sa in the exercise-04 namespace
