kubectl get pods -n maintenance -o wide
kubectl cordon node01
# A plain drain refuses: database is not managed by a controller and uses emptyDir.
#   kubectl drain node01 --ignore-daemonsets
#   error: cannot delete Pods that declare no controller (use --force to override): maintenance/database
# --force --delete-emptydir-data would DELETE the database pod and its data - not allowed here.
# Move only the web pods: with node01 cordoned, the Deployment recreates them elsewhere.
kubectl delete pod -n maintenance -l app=web --field-selector spec.nodeName=node01
# Alternative: kubectl drain node01 --ignore-daemonsets --pod-selector=app=web
#   but --pod-selector matches pods in ALL namespaces - any other unmanaged app=web pod makes it fail.
kubectl get pods -n maintenance -o wide      # database still on node01, web pods elsewhere (or Pending)
kubectl get node node01                      # Ready,SchedulingDisabled
# After the maintenance:  kubectl uncordon node01
