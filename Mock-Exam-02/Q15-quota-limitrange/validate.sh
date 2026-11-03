#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 15"
NS=batch-jobs; Q="quota batch-quota -n $NS"; LR="limitrange batch-limits -n $NS"
oneof "quota CPU" "$(jp '{.spec.hard.requests\.cpu}{.spec.hard.cpu}' $Q)" 10 10000m
oneof "quota memory" "$(jp '{.spec.hard.requests\.memory}{.spec.hard.memory}' $Q)" 20Gi 20480Mi
oneof "LimitRange type" "$(jp '{.spec.limits[0].type}' $LR)" Container Pod
oneof "min cpu" "$(jp '{.spec.limits[0].min.cpu}' $LR)" 500m 0.5
oneof "min memory" "$(jp '{.spec.limits[0].min.memory}' $LR)" 256Mi
oneof "max cpu" "$(jp '{.spec.limits[0].max.cpu}' $LR)" 4 4000m
oneof "max memory" "$(jp '{.spec.limits[0].max.memory}' $LR)" 8Gi 8192Mi
if try_pod $NS validate-too-big 5 2Gi 5 2Gi; then fail "a 5 CPU pod is admitted"; else pass "5 CPU pod rejected"; fi
if try_pod $NS validate-too-small 100m 128Mi 200m 256Mi; then fail "a 100m / 128Mi pod is admitted"; else pass "100m / 128Mi pod rejected"; fi
if try_pod $NS validate-fits 1 1Gi 2 2Gi; then pass "1 CPU / 1Gi pod (limits 2 / 2Gi) admitted"; else fail "a 1 CPU / 1Gi pod (limits 2 / 2Gi) is rejected"; fi
if grep -qi 'forbidden' /root/mock2/q15-rejected.txt 2>/dev/null; then pass "rejection saved in q15-rejected.txt"; else fail "/root/mock2/q15-rejected.txt missing or has no 'forbidden' error"; fi
summary
