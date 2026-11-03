#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-23; DP="deploy web -n $NS"
banner "Validating Question 23"
eq "replicas still 3" "$(jp '{.spec.replicas}' $DP)" 3
eq "3 replicas ready" "$(jp '{.status.readyReplicas}' $DP)" 3
eq "no Pending pods" "$(kubectl get pods -n $NS --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l)" 0
nonempty "cpu request still set" "$(jp '{.spec.template.spec.containers[0].resources.requests.cpu}' $DP)"
nonempty "memory request still set" "$(jp '{.spec.template.spec.containers[0].resources.requests.memory}' $DP)"
if [ "$(jp '{.spec.template.spec.containers[0].resources.requests.memory}' $DP)" != 512Mi ]; then pass "memory request lowered from 512Mi"; else warn "memory request is still 512Mi"; fi
if [ -s /root/exercise-23-calculation.txt ]; then pass "calculation documented"; else warn "/root/exercise-23-calculation.txt is missing or empty"; fi
summary
