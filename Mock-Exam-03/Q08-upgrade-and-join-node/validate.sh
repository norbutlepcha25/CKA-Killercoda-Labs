#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 08"
CP=$(cp_node); W=$(cat /root/.cka-lab/mock3-q8-node 2>/dev/null); W=${W:-node01}
CPV=$(jp '{.status.nodeInfo.kubeletVersion}' node "$CP")
check "node $W is part of the cluster" kubectl get node "$W"
kubectl wait --for=condition=Ready node/"$W" --timeout=60s >/dev/null 2>&1
eq "node $W Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node "$W")" True
eq "kubelet version on $W" "$(jp '{.status.nodeInfo.kubeletVersion}' node "$W")" "$CPV"
KV=$(on_node "$W" "kubectl version --client 2>/dev/null" | sed -n 's/^Client Version: //p')
eq "kubectl version on $W" "$KV" "$CPV"
summary
