#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 14"
NS=storage-demo
eq "StorageClass ssd provisioner" "$(jp '{.provisioner}' sc ssd)" rancher.io/local-path
eq "reclaimPolicy" "$(jp '{.reclaimPolicy}' sc ssd)" Delete
eq "volumeBindingMode" "$(jp '{.volumeBindingMode}' sc ssd)" WaitForFirstConsumer
eq "PVC storageClassName" "$(jp '{.spec.storageClassName}' pvc my-ssd-claim -n $NS)" ssd
eq "PVC request" "$(jp '{.spec.resources.requests.storage}' pvc my-ssd-claim -n $NS)" 20Gi
kubectl wait --for=condition=Ready pod/app-using-ssd -n $NS --timeout=90s >/dev/null 2>&1
eq "PVC Bound" "$(jp '{.status.phase}' pvc my-ssd-claim -n $NS)" Bound
PV=$(jp '{.spec.volumeName}' pvc my-ssd-claim -n $NS)
nonempty "PV created for the claim" "$PV"
eq "PV belongs to StorageClass ssd" "$(jp '{.spec.storageClassName}' pv $PV)" ssd
eq "pod app-using-ssd Running" "$(jp '{.status.phase}' pod app-using-ssd -n $NS)" Running
if jp '{.spec.volumes[*].persistentVolumeClaim.claimName}' pod app-using-ssd -n $NS | grep -qw my-ssd-claim; then pass "pod uses my-ssd-claim"; else fail "pod does not use my-ssd-claim"; fi
check "pod can write to /data" kubectl exec app-using-ssd -n $NS -- sh -c 'echo ok > /data/check && cat /data/check'
summary
