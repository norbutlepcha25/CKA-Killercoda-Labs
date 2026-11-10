#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 19"
NS=project-lynx; F=/root/mock3/19/iptables.txt
eq "Pod p2-pod image" "$(jp '{.spec.containers[0].image}' pod p2-pod -n $NS)" nginx:1-alpine
eq "Pod p2-pod Running" "$(jp '{.status.phase}' pod p2-pod -n $NS)" Running
N=$(grep -c "project-lynx/p2-service" $F 2>/dev/null); N=${N:-0}
if [ "$N" -ge 3 ]; then pass "iptables.txt holds $N rules of p2-service"; else fail "iptables.txt holds $N p2-service rules (expected the full set from iptables-save)"; fi
if grep -v "project-lynx/p2-service" $F 2>/dev/null | grep -q '^-A'; then fail "iptables.txt contains rules of other Services"; else pass "iptables.txt contains only p2-service rules"; fi
if grep -q -- '--dport 3000' $F 2>/dev/null && grep -q 'DNAT' $F; then pass "rules show port 3000 and DNAT to the Pod"; else fail "rules do not show --dport 3000 and DNAT"; fi
if kubectl get svc p2-service -n $NS >/dev/null 2>&1; then fail "Service p2-service still exists (step 4)"; else pass "Service p2-service deleted"; fi
eq "no p2-service rules left in iptables" "$(iptables-save 2>/dev/null | grep -c 'project-lynx/p2-service')" 0
summary
