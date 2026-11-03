cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: batch-quota
  namespace: batch-jobs
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "10"
    limits.memory: 20Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: batch-limits
  namespace: batch-jobs
spec:
  limits:
  - type: Container
    min:
      cpu: 500m
      memory: 256Mi
    max:
      cpu: "4"
      memory: 8Gi
EOF
kubectl describe quota batch-quota -n batch-jobs
kubectl describe limitrange batch-limits -n batch-jobs
# kubectl run lost --requests/--limits in 1.24 - use --overrides (or YAML):
kubectl run too-big -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"too-big","image":"nginx:1.27","resources":{"requests":{"cpu":"5","memory":"2Gi"},"limits":{"cpu":"5","memory":"2Gi"}}}]}}' 2> /root/mock2/q15-rejected.txt
cat /root/mock2/q15-rejected.txt     # forbidden: maximum cpu usage per Container is 4, but limit is 5
kubectl run fits -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"fits","image":"nginx:1.27","resources":{"requests":{"cpu":"1","memory":"1Gi"},"limits":{"cpu":"2","memory":"2Gi"}}}]}}'
kubectl get pod fits -n batch-jobs
# LimitRange max with no default: containers without limits get limits = max (4 CPU / 8Gi) and,
# if requests are missing too, requests = those limits.
