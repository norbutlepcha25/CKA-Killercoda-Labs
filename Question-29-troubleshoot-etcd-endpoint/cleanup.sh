#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
if [ -f /root/.cka-lab/kube-apiserver.yaml.bak ]; then
  cp /root/.cka-lab/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml
  echo "Restored kube-apiserver manifest - waiting for the API server ..."
  for i in $(seq 1 60); do kubectl get nodes >/dev/null 2>&1 && break; sleep 3; done
fi
true
