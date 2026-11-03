#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 12"
S="sts database-cluster -n default"
eq "Service database-cluster is headless" "$(jp '{.spec.clusterIP}' svc database-cluster -n default)" None
eq "Service port" "$(jp '{.spec.ports[0].port}' svc database-cluster -n default)" 5432
eq "Service selector" "$(jp '{.spec.selector.app}' svc database-cluster -n default)" database-cluster
eq "StatefulSet replicas" "$(jp '{.spec.replicas}' $S)" 3
eq "StatefulSet serviceName" "$(jp '{.spec.serviceName}' $S)" database-cluster
eq "image" "$(jp '{.spec.template.spec.containers[0].image}' $S)" postgres:17-alpine
eq "volumeClaimTemplate storage" "$(jp '{.spec.volumeClaimTemplates[0].spec.resources.requests.storage}' $S)" 10Gi
eq "volumeClaimTemplate storageClassName" "$(jp '{.spec.volumeClaimTemplates[0].spec.storageClassName}' $S)" local-path
kubectl rollout status $S --timeout=180s >/dev/null 2>&1
eq "3 pods ready" "$(jp '{.status.readyReplicas}' $S)" 3
for i in 0 1 2; do
  eq "PVC data-database-cluster-$i Bound" "$(jp '{.status.phase}' pvc data-database-cluster-$i -n default)" Bound
done
if kubectl exec database-cluster-1 -n default -- nslookup database-cluster-0.database-cluster.default.svc.cluster.local >/dev/null 2>&1; then pass "database-cluster-0.database-cluster resolves"; else fail "database-cluster-0.database-cluster does not resolve"; fi
summary
