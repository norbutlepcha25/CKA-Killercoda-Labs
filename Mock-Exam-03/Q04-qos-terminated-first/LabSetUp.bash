#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=project-c13; kubectl create ns $NS >/dev/null
kubectl create deployment c13-2x3-api -n $NS --image=nginx:1-alpine --replicas=3 >/dev/null
kubectl set resources deploy c13-2x3-api -n $NS --requests=cpu=50m,memory=20Mi >/dev/null
kubectl create deployment c13-2x3-web -n $NS --image=nginx:1-alpine --replicas=2 >/dev/null
kubectl set resources deploy c13-2x3-web -n $NS --requests=cpu=50m,memory=10Mi --limits=cpu=50m,memory=10Mi >/dev/null
kubectl create deployment c13-3cc-runner-heavy -n $NS --image=nginx:1-alpine --replicas=3 >/dev/null
kubectl create deployment c13-3cc-data -n $NS --image=nginx:1-alpine --replicas=2 >/dev/null
kubectl set resources deploy c13-3cc-data -n $NS --limits=memory=30Mi >/dev/null
kubectl create deployment c13-3cc-web -n $NS --image=nginx:1-alpine --replicas=2 >/dev/null
kubectl set resources deploy c13-3cc-web -n $NS --requests=cpu=30m >/dev/null
for d in $(kubectl get deploy -n $NS -o name); do kubectl rollout status $d -n $NS --timeout=180s >/dev/null; done
mkdir -p /root/mock3/4
echo "Q04 ready: namespace project-c13"
