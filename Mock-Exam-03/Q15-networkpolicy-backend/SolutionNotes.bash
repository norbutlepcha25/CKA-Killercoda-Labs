kubectl -n project-snake get pod -L app -o wide
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:                     # rule 1: db1 AND port 1111
    - podSelector:
        matchLabels:
          app: db1
    ports:
    - protocol: TCP
      port: 1111
  - to:                     # rule 2: db2 AND port 2222
    - podSelector:
        matchLabels:
          app: db2
    ports:
    - protocol: TCP
      port: 2222
YAML
# WRONG: one rule with both selectors and both ports = (db1 OR db2) AND (1111 OR 2222)
# -> backend could reach db2:1111 and db1:2222.
kubectl -n project-snake exec backend-0 -- curl -s -m3 <db1-ip>:1111   # database one
kubectl -n project-snake exec backend-0 -- curl -s -m3 <vault-ip>:3333 # times out
