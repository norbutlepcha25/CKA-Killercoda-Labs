#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2
NS=payments; D=deploy/payment-service
kubectl create ns $NS >/dev/null
kubectl create deployment payment-service -n $NS --image=nginx:1.25 --replicas=3 >/dev/null
kubectl annotate $D -n $NS kubernetes.io/change-cause="v1.0 initial release (nginx:1.25)" --overwrite >/dev/null
kubectl rollout status $D -n $NS --timeout=180s >/dev/null
step(){ kubectl annotate $D -n $NS kubernetes.io/change-cause="$2" --overwrite >/dev/null
        kubectl set image $D -n $NS nginx=$1 >/dev/null; }
step nginx:1.26 "v1.1 performance fixes (nginx:1.26)"; kubectl rollout status $D -n $NS --timeout=180s >/dev/null
step nginx:1.27 "v1.2 stable (nginx:1.27)";          kubectl rollout status $D -n $NS --timeout=180s >/dev/null
step nginx:1.27-payments-hotfix "v1.3 hotfix"
sleep 5
echo "Q02 ready: Deployment payments/payment-service."
