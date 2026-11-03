kubectl create ns exercise-15
kubectl get gatewayclass                      # eg
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: exercise-15
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF
kubectl create deployment web -n exercise-15 --image=nginx:1.28 --replicas=2
kubectl expose deployment web -n exercise-15 --name=web-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: exercise-15
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-svc
      port: 80
EOF
kubectl get gateway web-gateway -n exercise-15          # PROGRAMMED True
kubectl describe httproute web-route -n exercise-15     # Accepted / ResolvedRefs True
# Bonus test through the gateway:
SVC=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway -o jsonpath='{.items[0].metadata.name}')
NP=$(kubectl get svc $SVC -n envoy-gateway-system -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s http://node01:$NP | head -4
