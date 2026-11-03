#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
if [ -f /root/.cka-lab/mock1-q11-kube-scheduler.yaml ]; then
  cp /root/.cka-lab/mock1-q11-kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml
  rm -f /root/.cka-lab/mock1-q11-kube-scheduler.yaml
fi
kubectl delete pod sched-test --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
rm -f /root/mock1/q11-cause.txt
true
