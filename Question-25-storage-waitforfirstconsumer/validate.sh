#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-25
banner "Validating Question 25"
eq "StorageClass provisioner" "$(jp '{.provisioner}' sc local-storage)" kubernetes.io/no-provisioner
eq "StorageClass volumeBindingMode" "$(jp '{.volumeBindingMode}' sc local-storage)" WaitForFirstConsumer
eq "PV capacity 1Gi" "$(jp '{.spec.capacity.storage}' pv local-pv-1)" 1Gi
eq "PV accessMode ReadWriteOnce" "$(jp '{.spec.accessModes[0]}' pv local-pv-1)" ReadWriteOnce
eq "PV storageClassName local-storage" "$(jp '{.spec.storageClassName}' pv local-pv-1)" local-storage
eq "PV local path /tmp/k8s-pv" "$(jp '{.spec.local.path}' pv local-pv-1)" /tmp/k8s-pv
AFF=$(jp '{.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0]}' pv local-pv-1)
nonempty "PV has nodeAffinity (node: $AFF)" "$AFF"
eq "PVC local-pvc Bound" "$(jp '{.status.phase}' pvc local-pvc -n $NS)" Bound
eq "PVC bound to local-pv-1" "$(jp '{.spec.volumeName}' pvc local-pvc -n $NS)" local-pv-1
eq "app-pod Running" "$(jp '{.status.phase}' pod app-pod -n $NS)" Running
eq "app-pod uses local-pvc" "$(jp '{.spec.volumes[?(@.persistentVolumeClaim)].persistentVolumeClaim.claimName}' pod app-pod -n $NS)" local-pvc
eq "app-pod mounts at /data" "$(jp '{.spec.containers[0].volumeMounts[0].mountPath}' pod app-pod -n $NS)" /data
eq "app-pod scheduled on the PV node" "$(jp '{.spec.nodeName}' pod app-pod -n $NS)" "$AFF"
if [ -n "$(kubectl exec app-pod -n $NS -- cat /data/test.txt 2>/dev/null)" ]; then pass "/data/test.txt written"; else fail "/data/test.txt missing or empty"; fi
summary
