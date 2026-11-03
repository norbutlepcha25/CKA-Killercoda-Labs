#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
T=$(cat /root/upgrade-target.txt 2>/dev/null)
banner "Validating Question 09 (target ${T:-unknown})"
[ -n "$T" ] || { fail "/root/upgrade-target.txt missing - run the lab setup first"; summary; }
CP=$(cp_node); W=$(worker_node)
eq "kubeadm on $CP is $T" "$(kubeadm version -o short 2>/dev/null)" "$T"
eq "kubeadm on $W is $T" "$(on_node "$W" 'kubeadm version -o short' 2>/dev/null)" "$T"
eq "kube-apiserver image is $T" "$(kubectl get pod -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | awk -F: '{print $NF}')" "$T"
for n in $CP $W; do
  eq "node $n kubelet version $T" "$(jp '{.status.nodeInfo.kubeletVersion}' node $n)" "$T"
  eq "node $n Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $n)" True
  eq "node $n schedulable (uncordoned)" "$(jp '{.spec.unschedulable}' node $n)" ""
done
eq "kubectl client is $T" "$(kubectl version --client -o json 2>/dev/null | grep -m1 gitVersion | sed 's/.*"\(v[^"]*\)".*/\1/')" "$T"
summary
