#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 07"
eq "Service mysql is headless (clusterIP None)" "$(jp '{.spec.clusterIP}' svc mysql)" None
eq "Service selector app=mysql" "$(jp '{.spec.selector.app}' svc mysql)" mysql
for i in 0 1 2; do
  eq "PVC data-mysql-$i is Bound" "$(jp '{.status.phase}' pvc data-mysql-$i)" Bound
done
if kubectl get statefulset mysql >/dev/null 2>&1; then
  eq "StatefulSet serviceName mysql" "$(jp '{.spec.serviceName}' statefulset mysql)" mysql
  eq "StatefulSet image nginx:1.28" "$(jp '{.spec.template.spec.containers[0].image}' statefulset mysql)" nginx:1.28
  eq "volumeClaimTemplate named data" "$(jp '{.spec.volumeClaimTemplates[0].metadata.name}' statefulset mysql)" data
  warn "StatefulSet still exists - task 7 asks you to delete it and confirm the PVCs remain"
else
  pass "StatefulSet deleted and the PVCs survived (task 7)"
fi
summary
