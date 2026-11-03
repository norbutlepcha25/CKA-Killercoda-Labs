#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-05
banner "Validating Question 05"
for p in frontend backend attacker; do
  eq "pod $p Running" "$(jp '{.status.phase}' pod $p -n $NS)" Running
  eq "pod $p label role=$p" "$(jp '{.metadata.labels.role}' pod $p -n $NS)" "$p"
done
NP="networkpolicy backend-policy -n $NS"
check "NetworkPolicy backend-policy exists" kubectl get $NP
eq "policy selects role=backend" "$(jp '{.spec.podSelector.matchLabels.role}' $NP)" backend
T=$(jp '{.spec.policyTypes}' $NP)
if echo "$T" | grep -q Ingress && echo "$T" | grep -q Egress; then pass "policyTypes Ingress + Egress"; else fail "policyTypes should include Ingress and Egress (got $T)"; fi
eq "ingress from role=frontend" "$(jp '{.spec.ingress[0].from[0].podSelector.matchLabels.role}' $NP)" frontend
eq "ingress port 80" "$(jp '{.spec.ingress[0].ports[0].port}' $NP)" 80
if jp '{range .spec.egress[*].ports[*]}{.protocol}/{.port}{"\n"}{end}' $NP | grep -q '^UDP/53$'; then pass "egress allows UDP 53"; else fail "egress should allow UDP 53"; fi
IP=$(jp '{.status.podIP}' pod backend -n $NS)
eq "frontend -> backend:80 works" "$(kubectl exec frontend -n $NS -- curl -s -m3 -o /dev/null -w '%{http_code}' http://$IP 2>/dev/null)" 200
if kubectl exec attacker -n $NS -- curl -s -m3 -o /dev/null http://$IP >/dev/null 2>&1; then fail "attacker can reach backend (should be blocked)"; else pass "attacker -> backend is blocked"; fi
summary
