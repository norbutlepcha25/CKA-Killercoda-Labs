cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "4"
    limits.memory: 8Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
  namespace: test
spec:
  limits:
  - type: Container
    min:
      cpu: 100m
      memory: 128Mi
EOF
kubectl describe quota test-quota -n test
kubectl describe limitrange test-limits -n test
# kubectl run has no --requests flag any more (removed in 1.24) - use --overrides or YAML:
kubectl run big -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"big","image":"nginx:1.27","resources":{"requests":{"cpu":"6","memory":"4Gi"},"limits":{"cpu":"6","memory":"4Gi"}}}]}}' 2> /root/mock1/q13-rejected.txt
cat /root/mock1/q13-rejected.txt     # forbidden: exceeded quota: test-quota, requested: ... cpu=6 ...
kubectl run tiny -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"tiny","image":"nginx:1.27","resources":{"requests":{"cpu":"50m","memory":"64Mi"},"limits":{"cpu":"50m","memory":"64Mi"}}}]}}'
#   forbidden: minimum cpu usage per Container is 100m, but request is 50m
# Note: a 2 CPU / 2Gi pod (the original wording) FITS a 4 CPU / 8Gi quota - it would be admitted.
# With limits.* in the quota, every pod must also set limits (or get them from a LimitRange default).
