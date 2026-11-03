#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 06"
NS=monitoring
if helm list -n $NS -o json 2>/dev/null | grep -q '"name":"monitoring-stack"'; then pass "release monitoring-stack exists in $NS"; else fail "release monitoring-stack not found in namespace $NS"; fi
if helm list -n $NS -o json 2>/dev/null | grep -q '"status":"deployed"'; then pass "release status deployed"; else fail "release is not in status deployed"; fi
if helm list -n $NS -o json 2>/dev/null | grep -q '"chart":"monitoring-0.1.0"'; then pass "release uses chart monitoring-0.1.0"; else fail "release does not use the local monitoring chart"; fi
V=$(helm get values monitoring-stack -n $NS -o json 2>/dev/null | tr -d ' ')
echo "$V" | grep -q '"replica_count":3' && pass "value replica_count=3" || fail "value replica_count=3 not set (got $V)"
echo "$V" | grep -q '"storage_size":"50Gi"' && pass "value storage_size=50Gi" || fail "value storage_size=50Gi not set"
echo "$V" | grep -q '"persistence":true' && pass "value persistence=true (boolean)" || fail "value persistence=true not set as a boolean"
eq "Deployment monitoring-stack replicas" "$(jp '{.spec.replicas}' deploy monitoring-stack -n $NS)" 3
check "Deployment monitoring-stack rolled out" kubectl rollout status deploy/monitoring-stack -n $NS --timeout=60s
eq "PVC monitoring-stack-data size" "$(jp '{.spec.resources.requests.storage}' pvc monitoring-stack-data -n $NS)" 50Gi
summary
