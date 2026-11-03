#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-13
banner "Validating Question 13"
if helm repo list 2>/dev/null | grep -q '^bitnami.*charts.bitnami.com/bitnami'; then pass "repo bitnami added"; else fail "helm repo bitnami not added"; fi
eq "release web is deployed" "$(helm status web -n $NS 2>/dev/null | awk '/^STATUS:/{print $2}')" deployed
if helm list -n $NS 2>/dev/null | awk '$1=="web"' | grep -q 'nginx-'; then pass "release uses the nginx chart"; else fail "release web does not use the nginx chart"; fi
H=$(helm history web -n $NS 2>/dev/null | tail -n +2)
C=$(echo "$H" | grep -c .)
if [ "$C" -ge 3 ]; then pass "history has $C revisions (install, upgrade, rollback)"; else fail "history has $C revision(s) - expected 3"; fi
if echo "$H" | grep -q 'Rollback to 1'; then pass "rolled back to revision 1"; else fail "no 'Rollback to 1' in history"; fi
DEP="deploy -n $NS -l app.kubernetes.io/instance=web"
eq "deployment replicas back to 2" "$(jp '{.items[0].spec.replicas}' $DEP)" 2
R=$(jp '{.items[0].status.readyReplicas}' $DEP)
if [ "${R:-0}" = 2 ]; then pass "2 pods ready"; else warn "pods not ready (${R:-0}/2) - see the ImagePullBackOff note in the solution"; fi
summary
