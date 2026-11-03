cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/no-provisioner
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 5Gi
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  hostPath:
    path: /mnt/fast-ssd
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-storage
  namespace: databases
spec:
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 5Gi
EOF
kubectl get pvc db-storage -n databases            # Bound to db-pv
# (kubectl has no "set volume" - that is an OpenShift oc command). Patch or kubectl edit:
kubectl patch deployment db-app -n databases --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"data","persistentVolumeClaim":{"claimName":"db-storage"}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"data","mountPath":"/data"}]}]'
kubectl rollout status deployment/db-app -n databases
kubectl exec deploy/db-app -n databases -- df -h /data
# Note: hostPath is node-local. It satisfies ReadWriteMany for this lab, but real shared storage
# (NFS, CephFS, EFS, Filestore ...) is what makes RWX useful across nodes.
