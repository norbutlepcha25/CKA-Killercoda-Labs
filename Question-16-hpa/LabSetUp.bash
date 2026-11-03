#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
if ! kubectl get deploy metrics-server -n kube-system >/dev/null 2>&1; then
  echo "Installing metrics-server ..."
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null
  kubectl patch deployment metrics-server -n kube-system --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null
fi
kubectl rollout status deployment metrics-server -n kube-system --timeout=180s
echo "Waiting for metrics to become available ..."
for i in $(seq 1 24); do kubectl top nodes >/dev/null 2>&1 && break; sleep 5; done
kubectl top nodes 2>/dev/null || echo "metrics not ready yet - give it another minute"
echo "Lab ready. Namespace exercise-16 does not exist yet."
