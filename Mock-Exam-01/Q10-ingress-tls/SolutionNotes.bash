cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts: ["api.example.com"]
    secretName: api-tls-cert
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-health
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"     # only for the paths of THIS Ingress
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /health
        pathType: Exact
        backend:
          service:
            name: api
            port:
              number: 80
EOF
IP=$(kubectl get node controlplane -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
HP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
SP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
curl -sk --resolve api.example.com:$SP:$IP https://api.example.com:$SP/api/                          # api says hello
curl -s -o /dev/null -w '%{http_code}\n' --resolve api.example.com:$HP:$IP http://api.example.com:$HP/api/    # 308
curl -s --resolve api.example.com:$HP:$IP http://api.example.com:$HP/health                          # api says hello
# Why two Ingresses: once a host has TLS, ingress-nginx redirects HTTP -> HTTPS (308).
# The ssl-redirect annotation is per Ingress, so /health lives in its own Ingress with redirect off.
