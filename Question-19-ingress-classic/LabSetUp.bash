#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
IV=controller-v1.13.3
if ! kubectl get deploy ingress-nginx-controller -n ingress-nginx >/dev/null 2>&1; then
  echo "Installing ingress-nginx ($IV, NodePort) ..."
  kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/$IV/deploy/static/provider/baremetal/deploy.yaml" >/dev/null
fi
kubectl wait --for=condition=Complete job -n ingress-nginx --all --timeout=180s >/dev/null 2>&1
kubectl wait --for=condition=Available deploy/ingress-nginx-controller -n ingress-nginx --timeout=300s >/dev/null
# the admission webhook answers a little after the Deployment is Available
for i in $(seq 1 30); do
  printf 'apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:\n  name: webhook-probe\n  namespace: default\nspec:\n  ingressClassName: nginx\n  defaultBackend:\n    service:\n      name: none\n      port:\n        number: 80\n' \
    | kubectl apply --dry-run=server -f - >/dev/null 2>&1 && break
  sleep 5
done
kubectl get ingressclass
echo "Lab ready. IngressClass nginx is installed (controller exposed as NodePort in ns ingress-nginx)."
