#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-12; PV="pv my-pv"
banner "Validating Question 12"
check "namespace $NS exists" kubectl get ns $NS
eq "PV capacity 1Gi" "$(jp '{.spec.capacity.storage}' $PV)" 1Gi
eq "PV accessMode ReadWriteOnce" "$(jp '{.spec.accessModes[0]}' $PV)" ReadWriteOnce
eq "PV storageClassName manual" "$(jp '{.spec.storageClassName}' $PV)" manual
eq "PV reclaim policy Retain" "$(jp '{.spec.persistentVolumeReclaimPolicy}' $PV)" Retain
eq "PV hostPath /data/exercise-12" "$(jp '{.spec.hostPath.path}' $PV)" /data/exercise-12
eq "PV was claimed by exercise-12/my-pvc" "$(jp '{.spec.claimRef.namespace}/{.spec.claimRef.name}' $PV)" exercise-12/my-pvc
if kubectl get pvc my-pvc -n $NS >/dev/null 2>&1; then
  eq "PVC my-pvc Bound" "$(jp '{.status.phase}' pvc my-pvc -n $NS)" Bound
  eq "PVC request 500Mi" "$(jp '{.spec.resources.requests.storage}' pvc my-pvc -n $NS)" 500Mi
  warn "PVC still exists - finish task 8 (delete pod + PVC, PV should become Released)"
else
  eq "PV status Released after PVC deletion" "$(jp '{.status.phase}' $PV)" Released
fi
FOUND=""
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  on_node "$n" "test -s /data/exercise-12/test.txt" 2>/dev/null && FOUND="$n"
done
if [ -n "$FOUND" ]; then pass "test.txt was written to the volume (found on $FOUND)"; else fail "no /data/exercise-12/test.txt on any node"; fi
summary
