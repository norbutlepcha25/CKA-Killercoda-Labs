cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /Volumes/Data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-t230
spec:
  storageClassName: ""          # only needed when the cluster has a default StorageClass
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
YAML
kubectl -n project-t230 get pv,pvc                 # both Bound
kubectl -n project-t230 create deploy safari --image=httpd:2-alpine --dry-run=client -o yaml > 6_dep.yaml
# add under spec.template.spec:
#   volumes:
#   - name: data
#     persistentVolumeClaim:
#       claimName: safari-pvc
# and under the container:
#   volumeMounts:
#   - name: data
#     mountPath: /tmp/safari-data
kubectl apply -f 6_dep.yaml
kubectl -n project-t230 describe pod -l app=safari | grep -A2 Mounts:
