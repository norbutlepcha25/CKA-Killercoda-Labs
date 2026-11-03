#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 11"
P="pdb app-pdb -n pdb-demo"
check "PDB app-pdb exists" kubectl get $P
eq "PDB selects app=my-app" "$(jp '{.spec.selector.matchLabels.app}' $P)" my-app
B="$(jp '{.spec.minAvailable}' $P)|$(jp '{.spec.maxUnavailable}' $P)"
oneof "budget allows at most 2 disrupted pods" "$B" "8|" "|2" "80%|" "|20%"
W=$(worker_node)
if [ "$(jp '{.spec.unschedulable}' node $W)" = true ]; then fail "$W is still cordoned - uncordon it"; else pass "$W is schedulable again"; fi
kubectl rollout status deploy/my-app -n pdb-demo --timeout=120s >/dev/null 2>&1
eq "10 replicas available" "$(jp '{.status.availableReplicas}' deploy my-app -n pdb-demo)" 10
eq "PDB allows 2 disruptions now" "$(jp '{.status.disruptionsAllowed}' $P)" 2
summary
