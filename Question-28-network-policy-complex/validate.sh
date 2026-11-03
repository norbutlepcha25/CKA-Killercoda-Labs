#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 28"
for ns in frontend backend database; do
  C=$(kubectl get netpol -n $ns --no-headers 2>/dev/null | wc -l)
  if [ "$C" -ge 1 ]; then pass "$ns has $C NetworkPolic(y/ies)"; else fail "$ns has no NetworkPolicy"; fi
done
FE="kubectl exec -n frontend deploy/frontend --"; BE="kubectl exec -n backend deploy/backend --"
if $FE curl -s -m4 http://backend.backend.svc.cluster.local:8080 2>/dev/null | grep -q backend-ok; then pass "frontend -> backend:8080 allowed"; else fail "frontend cannot reach backend:8080"; fi
if $FE timeout 4 bash -c '</dev/tcp/database.database.svc.cluster.local/6379' >/dev/null 2>&1; then fail "frontend can reach database (should be blocked)"; else pass "frontend -> database blocked"; fi
if $BE sh -c 'echo PING | nc -w 4 database.database.svc.cluster.local 6379' 2>/dev/null | grep -q PONG; then pass "backend -> database:6379 allowed"; else fail "backend cannot reach database:6379"; fi
if $BE wget -q -T 4 -O- http://frontend.frontend.svc.cluster.local >/dev/null 2>&1; then fail "backend can reach frontend (should be blocked)"; else pass "backend -> frontend blocked"; fi
kubectl delete pod np-outsider --ignore-not-found --now >/dev/null 2>&1
if kubectl run np-outsider --image=busybox:1.36 --restart=Never --rm -i --quiet -- wget -q -T 4 -O- http://backend.backend.svc.cluster.local:8080 2>/dev/null | grep -q backend-ok; then
  fail "a pod in default can reach backend (default deny missing)"; else pass "default namespace -> backend blocked"; fi
if $FE getent hosts kubernetes.default.svc.cluster.local >/dev/null 2>&1; then pass "DNS works in frontend"; else fail "DNS broken in frontend"; fi
if $BE nslookup kubernetes.default.svc.cluster.local 2>/dev/null | grep -q 'Name:'; then pass "DNS works in backend"; else fail "DNS broken in backend"; fi
summary
