#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 03"
W=$(worker_node); NS=maintenance
eq "node $W is unschedulable (cordoned)" "$(jp '{.spec.unschedulable}' node $W)" true
eq "database pod is the original pod (not evicted/recreated)" "$(jp '{.metadata.uid}' pod database -n $NS)" "$(cat /root/.cka-lab/mock1-q03-db-uid 2>/dev/null)"
eq "database pod Running" "$(jp '{.status.phase}' pod database -n $NS)" Running
eq "database pod still on $W" "$(jp '{.spec.nodeName}' pod database -n $NS)" "$W"
eq "Deployment web still wants 3 replicas" "$(jp '{.spec.replicas}' deploy web -n $NS)" 3
ON=$(kubectl get pods -n $NS -l app=web -o jsonpath='{range .items[?(@.spec.nodeName=="'$W'")]}{.metadata.name}{" "}{end}' 2>/dev/null)
if [ -z "$ON" ]; then pass "no web pods left on $W"; else fail "web pods still on $W: $ON"; fi
summary
