#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
M=/etc/kubernetes/manifests/kube-apiserver.yaml
mkdir -p /root/.cka-lab
if grep -q -- '--etcd-servers=https://10.0.0.5:2379' $M; then
  echo "The API server is already broken from a previous run - fix it or run ./lab.sh 29 cleanup first."; exit 0
fi
cp $M /root/.cka-lab/kube-apiserver.yaml.bak      # backup OUTSIDE the manifests dir
sed -i 's#--etcd-servers=.*#--etcd-servers=https://10.0.0.5:2379#' $M
echo "Breaking the API server ..."
sleep 30
kubectl get nodes 2>&1 | head -2 || true
echo "Lab ready. The API server is down."
