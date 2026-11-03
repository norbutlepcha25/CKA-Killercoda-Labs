#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
mkdir -p /root/mock1 /root/.cka-lab
cp $M /root/.cka-lab/mock1-q11-kube-scheduler.yaml
sed -i '/kubeconfig=/s#/etc/kubernetes/scheduler.conf#/etc/kubernetes/scheduler.config#' $M
echo "Breaking the scheduler ..."
sleep 30
kubectl run sched-test --image=nginx:1.27 >/dev/null 2>&1
echo "Q11 ready: the kube-scheduler is down."
