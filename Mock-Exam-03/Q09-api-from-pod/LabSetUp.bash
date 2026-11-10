#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-swan >/dev/null
kubectl -n project-swan create sa secret-reader >/dev/null
kubectl create clusterrole mock3-secret-reader --verb=get,list --resource=secrets >/dev/null
kubectl create clusterrolebinding mock3-secret-reader --clusterrole=mock3-secret-reader --serviceaccount=project-swan:secret-reader >/dev/null
kubectl -n project-swan create secret generic read-me --from-literal=token=f3201396-f5d8-4584-a6f1-6f2dfdb3875e >/dev/null
mkdir -p /root/mock3/9
echo "Q09 ready: ServiceAccount project-swan/secret-reader"
