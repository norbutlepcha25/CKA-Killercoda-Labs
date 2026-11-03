# Question 13 - Helm Install, Upgrade and Rollback  (Cluster Architecture | Medium | 15 min)
#
# Tasks
# 1. Add the Bitnami chart repository (name bitnami, https://charts.bitnami.com/bitnami) and update the repo cache
# 2. Install NGINX (chart bitnami/nginx) using Helm in a namespace called exercise-13:
#    - Release name: web
#    - Set replicaCount=2
# 3. Verify the release is deployed and 2 pods are running
# 4. Upgrade the release to replicaCount=3
# 5. Check the release history and confirm there are 2 revisions
# 6. Roll back to revision 1
# 7. Verify the replica count is back to 2
