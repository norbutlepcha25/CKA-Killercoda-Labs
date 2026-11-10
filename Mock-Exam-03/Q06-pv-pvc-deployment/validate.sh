#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 06"
NS=project-t230
eq "PV safari-pv capacity" "$(jp '{.spec.capacity.storage}' pv safari-pv)" 2Gi
eq "PV safari-pv access modes" "$(jp '{.spec.accessModes[*]}' pv safari-pv)" ReadWriteOnce
eq "PV safari-pv hostPath" "$(jp '{.spec.hostPath.path}' pv safari-pv)" /Volumes/Data
eq "PV safari-pv has no storageClassName" "$(jp '{.spec.storageClassName}' pv safari-pv)" ""
eq "PVC safari-pvc Bound" "$(jp '{.status.phase}' pvc safari-pvc -n $NS)" Bound
eq "PVC safari-pvc bound to safari-pv" "$(jp '{.spec.volumeName}' pvc safari-pvc -n $NS)" safari-pv
eq "PVC safari-pvc request" "$(jp '{.spec.resources.requests.storage}' pvc safari-pvc -n $NS)" 2Gi
eq "PVC safari-pvc access modes" "$(jp '{.spec.accessModes[*]}' pvc safari-pvc -n $NS)" ReadWriteOnce
eq "Deployment safari image" "$(jp '{.spec.template.spec.containers[0].image}' deploy safari -n $NS)" httpd:2-alpine
if jp '{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}' deploy safari -n $NS | grep -qw safari-pvc; then pass "safari uses claim safari-pvc"; else fail "safari does not use claim safari-pvc"; fi
if jp '{.spec.template.spec.containers[*].volumeMounts[*].mountPath}' deploy safari -n $NS | grep -qw /tmp/safari-data; then pass "safari mounts /tmp/safari-data"; else fail "no mount at /tmp/safari-data"; fi
check "Deployment safari available" kubectl rollout status deploy/safari -n $NS --timeout=60s
summary
