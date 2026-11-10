#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 05"
B=/root/mock3/5/api-gateway
for env in staging prod; do
  NS=api-gateway-$env; MAX=4; [ $env = prod ] && MAX=6
  OUT=$(kubectl kustomize $B/$env 2>&1); RC=$?
  if [ $RC -eq 0 ]; then pass "$env: kustomize build works"; else fail "$env: kustomize build fails: $(echo "$OUT" | head -1)"; fi
  if [ $RC -eq 0 ] && ! echo "$OUT" | grep -q horizontal-scaling-config; then pass "$env: ConfigMap removed from the config"; else fail "$env: ConfigMap still in the config"; fi
  if kubectl get cm horizontal-scaling-config -n $NS >/dev/null 2>&1; then fail "$env: ConfigMap still exists in $NS"; else pass "$env: ConfigMap gone from $NS"; fi
  if [ $RC -eq 0 ] && echo "$OUT" | grep -q 'kind: HorizontalPodAutoscaler'; then pass "$env: HPA is part of the config"; else fail "$env: no HPA in the config"; fi
  eq "$env: HPA target" "$(jp '{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}' hpa api-gateway -n $NS)" Deployment/api-gateway
  eq "$env: HPA minReplicas" "$(jp '{.spec.minReplicas}' hpa api-gateway -n $NS)" 2
  eq "$env: HPA maxReplicas" "$(jp '{.spec.maxReplicas}' hpa api-gateway -n $NS)" $MAX
  eq "$env: HPA metric" "$(jp '{.spec.metrics[0].resource.name}/{.spec.metrics[0].resource.target.type}/{.spec.metrics[0].resource.target.averageUtilization}' hpa api-gateway -n $NS)" cpu/Utilization/50
done
summary
