#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node)
banner "Validating Question 08 (worker: $W)"
eq "worker $W is schedulable (uncordoned)" "$(jp '{.spec.unschedulable}' node $W)" ""
check "deployment drain-test exists" kubectl get deploy drain-test
eq "drain-test image nginx:1.27" "$(jp '{.spec.template.spec.containers[0].image}' deploy drain-test)" nginx:1.27
eq "drain-test scaled to 6" "$(jp '{.spec.replicas}' deploy drain-test)" 6
eq "6 replicas available" "$(jp '{.status.availableReplicas}' deploy drain-test)" 6
N=$(kubectl get pods -l app=drain-test --field-selector spec.nodeName=$W --no-headers 2>/dev/null | wc -l)
if [ "$N" -ge 1 ]; then pass "$N drain-test pod(s) scheduled on $W after uncordon"; else fail "no drain-test pods on $W"; fi
summary
