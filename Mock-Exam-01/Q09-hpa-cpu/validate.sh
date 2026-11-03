#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 09"
H="hpa web-app -n production"
check "HPA web-app exists" kubectl get $H
eq "scale target" "$(jp '{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}' $H)" Deployment/web-app
eq "minReplicas" "$(jp '{.spec.minReplicas}' $H)" 2
eq "maxReplicas" "$(jp '{.spec.maxReplicas}' $H)" 10
eq "CPU target utilization" "$(jp '{.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' $H)" 70
OK=0; for i in $(seq 1 12); do [ -n "$(jp '{.status.currentMetrics[0].resource.current.averageUtilization}' $H)" ] && { OK=1; break; }; sleep 5; done
if [ $OK = 1 ]; then pass "HPA reads CPU metrics"; else warn "HPA has no CPU metrics yet (metrics-server can need a minute)"; fi
summary
