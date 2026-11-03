#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-14; L=/root/kustomize-lab
banner "Validating Question 14"
for f in base/deployment.yaml base/service.yaml base/kustomization.yaml overlays/staging/kustomization.yaml; do
  check "file $L/$f exists" test -f "$L/$f"
done
OUT=$(kubectl kustomize "$L/overlays/staging" 2>/dev/null)
if echo "$OUT" | grep -q 'namespace: exercise-14'; then pass "overlay renders with namespace exercise-14"; else fail "overlay does not render namespace exercise-14"; fi
if echo "$OUT" | grep -q 'replicas: 3'; then pass "overlay renders replicas: 3"; else fail "overlay does not set replicas 3"; fi
eq "deployment app replicas 3" "$(jp '{.spec.replicas}' deploy app -n $NS)" 3
eq "3 replicas ready" "$(jp '{.status.readyReplicas}' deploy app -n $NS)" 3
eq "image nginx:1.27" "$(jp '{.spec.template.spec.containers[0].image}' deploy app -n $NS)" nginx:1.27
eq "deployment label env=staging" "$(jp '{.metadata.labels.env}' deploy app -n $NS)" staging
eq "3 running pods with env=staging" "$(kubectl get pods -n $NS -l env=staging --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)" 3
eq "service app-svc type ClusterIP" "$(jp '{.spec.type}' svc app-svc -n $NS)" ClusterIP
eq "service app-svc port 80" "$(jp '{.spec.ports[0].port}' svc app-svc -n $NS)" 80
summary
