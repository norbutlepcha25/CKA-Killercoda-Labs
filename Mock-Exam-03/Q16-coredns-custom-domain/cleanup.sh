#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
O=/root/.cka-lab/mock3-coredns.Corefile
if [ -s $O ]; then
  if [ "$(kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}')" != "$(cat $O)" ]; then
    kubectl create configmap coredns -n kube-system --from-file=Corefile=$O --dry-run=client -o yaml | kubectl replace -f - >/dev/null
    kubectl -n kube-system rollout restart deploy coredns >/dev/null
    kubectl -n kube-system rollout status deploy coredns --timeout=120s >/dev/null 2>&1
  fi
  rm -f $O
fi
kubectl delete pod mock3-dns-test --ignore-not-found --force --grace-period=0 >/dev/null 2>&1
rm -rf /root/mock3/16
true
