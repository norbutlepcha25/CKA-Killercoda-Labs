#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
EGV=v1.5.4
if ! kubectl get deploy envoy-gateway -n envoy-gateway-system >/dev/null 2>&1; then
  echo "Installing Envoy Gateway $EGV (Gateway API CRDs + controller) ..."
  kubectl apply --server-side --force-conflicts -f "https://github.com/envoyproxy/gateway/releases/download/$EGV/install.yaml" >/dev/null
fi
kubectl wait --for=condition=Available deploy/envoy-gateway -n envoy-gateway-system --timeout=300s >/dev/null
# GatewayClass "eg" whose proxies are exposed with a NodePort Service (no LoadBalancer on Killercoda)
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: nodeport-proxy
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService:
        type: NodePort
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: nodeport-proxy
    namespace: envoy-gateway-system
EOF
kubectl wait --for=condition=Accepted gatewayclass/eg --timeout=120s >/dev/null 2>&1
kubectl get gatewayclass
echo "Lab ready. GatewayClass eg (Envoy Gateway) is installed."
