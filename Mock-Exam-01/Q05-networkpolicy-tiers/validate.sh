#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 05"
NS=shop
IP(){ jp '{.status.podIP}' pod "$1" -n $NS; }
code(){ kubectl exec "$1" -n $NS -- curl -s -m3 -o /dev/null -w '%{http_code}' "http://$2" 2>/dev/null; }
SEL=$(jp '{range .items[*]}{.spec.podSelector.matchLabels.tier}{" "}{end}' networkpolicy -n $NS)
for t in frontend backend database; do
  if echo " $SEL " | grep -q " $t "; then pass "a NetworkPolicy selects tier=$t"; else fail "no NetworkPolicy selects tier=$t"; fi
done
F=$(IP frontend); B=$(IP backend); D=$(IP database)
eq "outsider -> frontend:80 allowed" "$(code outsider $F:80)" 200
eq "frontend -> backend:3000 allowed" "$(code frontend $B:3000)" 200
if [ "$(code outsider $B:3000)" = 200 ]; then fail "outsider -> backend:3000 should be blocked"; else pass "outsider -> backend:3000 blocked"; fi
eq "backend -> database:5432 allowed" "$(code backend $D:5432)" 200
if [ "$(code frontend $D:5432)" = 200 ]; then fail "frontend -> database:5432 should be blocked"; else pass "frontend -> database:5432 blocked"; fi
if [ "$(code outsider $D:5432)" = 200 ]; then fail "outsider -> database:5432 should be blocked"; else pass "outsider -> database:5432 blocked"; fi
summary
