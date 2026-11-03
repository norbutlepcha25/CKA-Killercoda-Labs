kubectl create ns exercise-19
kubectl create deployment web-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl create deployment api-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl expose deployment web-app -n exercise-19 --name=web-service --port=80 --target-port=80
kubectl expose deployment api-app -n exercise-19 --name=api-service --port=8080 --target-port=80
kubectl get endpoints -n exercise-19
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: exercise-19
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: web-service
      port:
        number: 80
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
EOF
kubectl get ingress -n exercise-19 -w          # ADDRESS gets filled in
kubectl describe ingress app-ingress -n exercise-19
NP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s -o /dev/null -w "%{http_code}\n" http://node01:$NP/        # 200
