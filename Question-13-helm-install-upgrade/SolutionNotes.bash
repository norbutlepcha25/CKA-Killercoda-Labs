helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install web bitnami/nginx -n exercise-13 --create-namespace --set replicaCount=2
helm list -n exercise-13
kubectl get pods -n exercise-13
helm upgrade web bitnami/nginx -n exercise-13 --reuse-values --set replicaCount=3
helm history web -n exercise-13                # 2 revisions
helm rollback web 1 -n exercise-13
kubectl get deploy -n exercise-13 -o jsonpath='{.items[0].spec.replicas}'   # 2
helm history web -n exercise-13                # 3 rows, last = "Rollback to 1"

# If the pods are stuck in ImagePullBackOff: Bitnami moved most free images to
# docker.io/bitnamilegacy in 2025. Add these flags to the install/upgrade:
#   --set image.repository=bitnamilegacy/nginx --set global.security.allowInsecureImages=true
# The Helm tasks (install/upgrade/history/rollback) are what is being tested.
