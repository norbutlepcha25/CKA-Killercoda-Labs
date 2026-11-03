kubectl create pdb app-pdb -n pdb-demo --selector=app=my-app --min-available=8
#   (equivalent: --max-unavailable=2)
kubectl get pdb app-pdb -n pdb-demo                 # ALLOWED DISRUPTIONS 2
kubectl drain node01 --ignore-daemonsets --timeout=60s
#   evicting pod pdb-demo/my-app-...
#   error when evicting pods/"my-app-..." -n "pdb-demo" (will retry after 5s): Cannot evict pod as it
#   would violate the pod's disruption budget.
# Drain evicts 2 pods, then waits until replacements are Ready elsewhere before evicting more.
# If the replacements can't start (e.g. the control plane is tainted), the drain stops at the budget.
kubectl get pods -n pdb-demo -o wide
kubectl uncordon node01
kubectl rollout status deploy/my-app -n pdb-demo
kubectl get pdb app-pdb -n pdb-demo
# A PDB only limits voluntary disruptions that use the Eviction API (drain, kubectl evict).
# kubectl delete pod and node failures ignore it.
