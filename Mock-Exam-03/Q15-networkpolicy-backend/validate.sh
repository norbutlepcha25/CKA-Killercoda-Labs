#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 15"
NS=project-snake; NP="networkpolicy np-backend -n $NS"
check "NetworkPolicy np-backend exists" kubectl get $NP
eq "policy selects app=backend" "$(jp '{.spec.podSelector.matchLabels.app}' $NP)" backend
if jp '{.spec.policyTypes[*]}' $NP | grep -qw Egress; then pass "policyTypes contains Egress"; else fail "policyTypes does not contain Egress"; fi
ip(){ jp '{.status.podIP}' pod "$1" -n $NS; }
cu(){ kubectl -n $NS exec backend-0 -- curl -s -m3 "$1" 2>/dev/null | tr -d '\r\n'; }
eq "backend -> db1:1111 allowed" "$(cu $(ip db1-0):1111)" "database one"
eq "backend -> db2:2222 allowed" "$(cu $(ip db2-0):2222)" "database two"
eq "backend -> vault:3333 blocked" "$(cu $(ip vault-0):3333)" ""
eq "backend -> db1:2222 blocked" "$(cu $(ip db1-0):2222)" ""
eq "backend -> db2:1111 blocked" "$(cu $(ip db2-0):1111)" ""
summary
