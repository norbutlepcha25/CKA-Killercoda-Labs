#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 04"
NS=databases
eq "StorageClass fast-ssd provisioner" "$(jp '{.provisioner}' sc fast-ssd)" kubernetes.io/no-provisioner
eq "PV db-pv capacity" "$(jp '{.spec.capacity.storage}' pv db-pv)" 5Gi
eq "PV db-pv storageClassName" "$(jp '{.spec.storageClassName}' pv db-pv)" fast-ssd
if jp '{.spec.accessModes}' pv db-pv | grep -q ReadWriteMany; then pass "PV db-pv is ReadWriteMany"; else fail "PV db-pv is not ReadWriteMany"; fi
eq "PV db-pv hostPath" "$(jp '{.spec.hostPath.path}' pv db-pv)" /mnt/fast-ssd
eq "PVC db-storage Bound" "$(jp '{.status.phase}' pvc db-storage -n $NS)" Bound
eq "PVC db-storage bound to db-pv" "$(jp '{.spec.volumeName}' pvc db-storage -n $NS)" db-pv
eq "PVC db-storage request" "$(jp '{.spec.resources.requests.storage}' pvc db-storage -n $NS)" 5Gi
if jp '{.spec.accessModes}' pvc db-storage -n $NS | grep -q ReadWriteMany; then pass "PVC is ReadWriteMany"; else fail "PVC is not ReadWriteMany"; fi
if jp '{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}' deploy db-app -n $NS | grep -qw db-storage; then pass "db-app uses claim db-storage"; else fail "db-app does not use claim db-storage"; fi
if jp '{.spec.template.spec.containers[*].volumeMounts[*].mountPath}' deploy db-app -n $NS | grep -qw /data; then pass "db-app mounts /data"; else fail "db-app has no mount at /data"; fi
check "db-app rollout complete" kubectl rollout status deploy/db-app -n $NS --timeout=60s
check "a db-app pod can write to /data" kubectl exec deploy/db-app -n $NS -- sh -c 'touch /data/.validate && rm /data/.validate'
summary
