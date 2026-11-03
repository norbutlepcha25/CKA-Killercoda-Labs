# Mock Exam 01 - Question 02 - RBAC  (Cluster Architecture | 7 min)
#
# The user dev-user must be able to list Pods and Deployments in namespace staging,
# and nothing in other namespaces.
#
# Tasks
# 1. Create a Role named staging-reader in namespace staging that allows listing Pods and Deployments
# 2. Create a RoleBinding named staging-reader-dev-user that grants this Role to the user dev-user
# 3. Verify with kubectl auth can-i (also check that dev-user can't list pods in namespace default)
