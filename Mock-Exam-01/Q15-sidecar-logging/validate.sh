#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 15"
P="pod app-with-logger -n default"
eq "pod Running" "$(jp '{.status.phase}' $P)" Running
eq "nginx image" "$(jp '{.spec.containers[?(@.name=="nginx")].image}' $P)" nginx:1.28
eq "logger image" "$(jp '{.spec.containers[?(@.name=="logger")].image}{.spec.initContainers[?(@.name=="logger")].image}' $P)" busybox:1.37
if jp '{.spec.volumes[*].emptyDir}' $P | grep -q '{}'; then pass "pod has an emptyDir volume"; else fail "no emptyDir volume"; fi
check "nginx writes a real file /var/log/nginx/access.log" kubectl exec app-with-logger -c nginx -- sh -c 'test -f /var/log/nginx/access.log && test ! -L /var/log/nginx/access.log'
check "logger sees /logs/access.log" kubectl exec app-with-logger -c logger -- test -f /logs/access.log
kubectl exec app-with-logger -c nginx -- curl -s -o /dev/null http://localhost/mock-exam-check >/dev/null 2>&1; sleep 2
if kubectl logs app-with-logger -c logger --tail=50 2>/dev/null | grep -q 'GET /mock-exam-check'; then pass "request shows up in logger logs"; else fail "request does not show up in kubectl logs -c logger"; fi
R=$(jp '{.status.containerStatuses[*].restartCount}{" "}{.status.initContainerStatuses[*].restartCount}' $P | tr ' ' '\n' | grep -v '^0*$' | grep -c .)
if [ "$R" = 0 ]; then pass "no container restarts"; else fail "containers have restarted"; fi
summary
