#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-06; DP="deploy webapp -n $NS"
banner "Validating Question 06"
check "deployment webapp exists" kubectl get $DP
eq "replicas 3" "$(jp '{.spec.replicas}' $DP)" 3
eq "3 replicas ready" "$(jp '{.status.readyReplicas}' $DP)" 3
eq "strategy RollingUpdate" "$(jp '{.spec.strategy.type}' $DP)" RollingUpdate
eq "maxSurge 1" "$(jp '{.spec.strategy.rollingUpdate.maxSurge}' $DP)" 1
eq "maxUnavailable 0" "$(jp '{.spec.strategy.rollingUpdate.maxUnavailable}' $DP)" 0
eq "current image nginx:1.28 (rolled back)" "$(jp '{.spec.template.spec.containers[0].image}' $DP)" nginx:1.28
if jp '{.items[*].spec.template.spec.containers[0].image}' rs -n $NS | grep -q 'nginx:1.29'; then pass "a ReplicaSet with nginx:1.29 exists (update was done)"; else fail "no ReplicaSet with nginx:1.29 - the image update was not done"; fi
REV=$(jp '{.metadata.annotations.deployment\.kubernetes\.io/revision}' $DP)
if [ "${REV:-0}" -ge 3 ]; then pass "revision is $REV (create, update, rollback)"; else fail "revision is ${REV:-0} - expected 3 after update + rollback"; fi
if [ -n "$(jp '{.metadata.annotations.kubernetes\.io/change-cause}' $DP)" ]; then pass "change-cause annotation recorded"; else warn "no kubernetes.io/change-cause annotation recorded"; fi
summary
