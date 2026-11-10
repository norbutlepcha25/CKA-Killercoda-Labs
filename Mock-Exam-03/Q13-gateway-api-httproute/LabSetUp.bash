#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_envoy_gateway
NS=project-r500; kubectl create ns $NS >/dev/null
for app in desktop mobile; do
  T="Web $(echo ${app:0:1} | tr a-z A-Z)${app:1} App"
  cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-$app-conf
  namespace: $NS
data:
  default.conf: |
    server {
      listen 80;
      default_type text/plain;
      location / { return 200 '$T'; }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-$app
  namespace: $NS
spec:
  selector:
    matchLabels:
      app: web-$app
  template:
    metadata:
      labels:
        app: web-$app
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        volumeMounts:
        - name: conf
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: conf
        configMap:
          name: web-$app-conf
---
apiVersion: v1
kind: Service
metadata:
  name: web-$app
  namespace: $NS
spec:
  selector:
    app: web-$app
  ports:
  - port: 80
YAML
done
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main
  namespace: project-r500
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
YAML
mkdir -p /root/mock3/13
cat > /root/mock3/13/ingress.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  ingressClassName: nginx
  rules:
  - host: r500.gateway
    http:
      paths:
      - backend:
          service:
            name: web-desktop
            port:
              number: 80
        path: /desktop
        pathType: Prefix
      - backend:
          service:
            name: web-mobile
            port:
              number: 80
        path: /mobile
        pathType: Prefix
YAML
kubectl -n $NS rollout status deploy/web-desktop --timeout=180s >/dev/null
kubectl -n $NS rollout status deploy/web-mobile --timeout=180s >/dev/null
SEL=gateway.envoyproxy.io/owning-gateway-name=main,gateway.envoyproxy.io/owning-gateway-namespace=$NS
for i in $(seq 1 60); do SVC=$(jp '{.items[0].metadata.name}' svc -n envoy-gateway-system -l $SEL); [ -n "$SVC" ] && break; sleep 3; done
NP=$(jp '{.spec.ports[?(@.port==80)].nodePort}' svc "$SVC" -n envoy-gateway-system)
IP=$(jp "{.status.addresses[?(@.type==\"InternalIP\")].address}" node $(cp_node))
sed -i '/ r500.gateway$/d' /etc/hosts; echo "$IP r500.gateway" >> /etc/hosts
echo "http://r500.gateway:$NP" > /root/mock3/13/gateway-url
kubectl wait --for=condition=Programmed gateway/main -n $NS --timeout=180s >/dev/null 2>&1
echo "Q13 ready: Gateway project-r500/main reachable at $(cat /root/mock3/13/gateway-url)"
