# default deny + DNS in every namespace
for ns in frontend backend database; do
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
EOF
done

cat <<'EOF' | kubectl apply -f -
# frontend may send to backend:8080
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-to-backend
  namespace: frontend
spec:
  podSelector:
    matchLabels: {tier: frontend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend accepts from frontend on 8080
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-from-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: frontend}
      podSelector:
        matchLabels: {tier: frontend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend may send to database:6379
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress-to-database
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: database}
      podSelector:
        matchLabels: {tier: database}
    ports: [{protocol: TCP, port: 6379}]
---
# database accepts from backend on 6379
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ingress-from-backend
  namespace: database
spec:
  podSelector:
    matchLabels: {tier: database}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 6379}]
EOF

# tests
kubectl exec -n frontend deploy/frontend -- curl -s -m3 http://backend.backend.svc.cluster.local:8080          # backend-ok
kubectl exec -n frontend deploy/frontend -- timeout 3 bash -c '</dev/tcp/database.database.svc.cluster.local/6379' || echo blocked
kubectl exec -n backend deploy/backend -- sh -c 'echo PING | nc -w 3 database.database.svc.cluster.local 6379'   # +PONG
kubectl exec -n backend deploy/backend -- wget -q -T 3 -O- http://frontend.frontend.svc.cluster.local || echo blocked
kubectl run outsider --image=busybox:1.36 --rm -it --restart=Never -- wget -q -T 3 -O- http://backend.backend.svc.cluster.local:8080   # blocked
kubectl exec -n backend deploy/backend -- nslookup kubernetes.default.svc.cluster.local                         # DNS works
