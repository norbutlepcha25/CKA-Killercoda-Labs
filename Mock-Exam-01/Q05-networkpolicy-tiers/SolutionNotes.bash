cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes: ["Ingress"]
  ingress:
  - ports:                       # no "from" = any source
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
EOF
B=$(kubectl get pod backend -n shop -o jsonpath='{.status.podIP}')
kubectl exec frontend -n shop -- curl -s -m3 -o /dev/null -w '%{http_code}\n' http://$B:3000   # 200
kubectl exec outsider -n shop -- curl -s -m3 http://$B:3000 || echo blocked                     # blocked
# policyTypes only lists Ingress, so egress stays open (DNS etc. keep working).
# Note: "protocol" belongs inside each "ports" entry - an ingress rule has only "from" and "ports".
