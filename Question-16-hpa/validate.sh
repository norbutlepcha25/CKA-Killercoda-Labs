#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-16; DP="deploy load-app -n $NS"
banner "Validating Question 16"
check "metrics-server works (kubectl top nodes)" kubectl top nodes
eq "load-app ready" "$(jp '{.status.readyReplicas}' $DP | awk '{print ($1>=1)?"yes":"no"}')" yes
eq "CPU request 50m" "$(jp '{.spec.template.spec.containers[0].resources.requests.cpu}' $DP)" 50m
eq "CPU limit 100m" "$(jp '{.spec.template.spec.containers[0].resources.limits.cpu}' $DP)" 100m
eq "service load-svc type ClusterIP" "$(jp '{.spec.type}' svc load-svc -n $NS)" ClusterIP
eq "service load-svc port 80" "$(jp '{.spec.ports[0].port}' svc load-svc -n $NS)" 80
nonempty "load-svc has endpoints" "$(jp '{.subsets[*].addresses[*].ip}' endpoints load-svc -n $NS)"
H=$(kubectl get hpa -n $NS -o jsonpath='{range .items[?(@.spec.scaleTargetRef.name=="load-app")]}{.metadata.name}{end}' 2>/dev/null)
if [ -z "$H" ]; then fail "no HPA targets deployment load-app"; summary; fi
pass "HPA $H targets load-app"
eq "minReplicas 1" "$(jp '{.spec.minReplicas}' hpa $H -n $NS)" 1
eq "maxReplicas 5" "$(jp '{.spec.maxReplicas}' hpa $H -n $NS)" 5
eq "metric target type Utilization" "$(jp '{.spec.metrics[0].resource.target.type}' hpa $H -n $NS)" Utilization
eq "averageUtilization 50" "$(jp '{.spec.metrics[0].resource.target.averageUtilization}' hpa $H -n $NS)" 50
if [ -n "$(jp '{.status.currentMetrics[0].resource.current.averageUtilization}' hpa $H -n $NS)" ]; then pass "HPA is reading CPU metrics"; else warn "HPA shows <unknown> CPU - wait a minute for metrics"; fi
summary
