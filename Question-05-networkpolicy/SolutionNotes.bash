kubectl create ns exercise-05
kubectl run frontend -n exercise-05 --image=nginx:1.27 --labels=role=frontend
kubectl run backend  -n exercise-05 --image=nginx:1.27 --labels=role=backend
kubectl run attacker -n exercise-05 --image=nginx:1.27 --labels=role=attacker
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: exercise-05
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - ports:
    - protocol: UDP
      port: 53
EOF
BACKEND_IP=$(kubectl get pod backend -n exercise-05 -o jsonpath='{.status.podIP}')
kubectl exec frontend -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # works
kubectl exec attacker -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # times out
