#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 13"
NS=test
check "ResourceQuota test-quota exists" kubectl get quota test-quota -n $NS
oneof "quota CPU requests" "$(jp '{.spec.hard.requests\.cpu}{.spec.hard.cpu}' quota test-quota -n $NS)" 4 4000m
oneof "quota memory requests" "$(jp '{.spec.hard.requests\.memory}{.spec.hard.memory}' quota test-quota -n $NS)" 8Gi 8192Mi
check "LimitRange test-limits exists" kubectl get limitrange test-limits -n $NS
oneof "LimitRange min cpu" "$(jp '{.spec.limits[0].min.cpu}' limitrange test-limits -n $NS)" 100m 0.1
oneof "LimitRange min memory" "$(jp '{.spec.limits[0].min.memory}' limitrange test-limits -n $NS)" 128Mi
if try_pod $NS validate-big 6 4Gi 6 4Gi; then fail "a 6 CPU / 4Gi pod is admitted"; else pass "6 CPU / 4Gi pod rejected"; fi
if try_pod $NS validate-tiny 50m 64Mi 50m 64Mi; then fail "a 50m / 64Mi pod is admitted"; else pass "50m / 64Mi pod rejected"; fi
if try_pod $NS validate-ok 200m 256Mi 500m 512Mi; then pass "a 200m / 256Mi pod is admitted"; else fail "a normal 200m / 256Mi pod (limits 500m/512Mi) is rejected"; fi
if grep -qiE 'forbidden|exceeded' /root/mock1/q13-rejected.txt 2>/dev/null; then pass "rejection saved in q13-rejected.txt"; else fail "/root/mock1/q13-rejected.txt missing or has no 'forbidden' error"; fi
summary
