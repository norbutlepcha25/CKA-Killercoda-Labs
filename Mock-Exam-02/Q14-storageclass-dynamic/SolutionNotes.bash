cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-ssd-claim
  namespace: storage-demo
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: ssd
  resources:
    requests:
      storage: 20Gi
EOF
kubectl get pvc -n storage-demo              # Pending - WaitForFirstConsumer waits for a pod
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-using-ssd
  namespace: storage-demo
spec:
  containers:
  - name: app
    image: nginx:1.27
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-ssd-claim
EOF
kubectl wait --for=condition=Ready pod/app-using-ssd -n storage-demo
kubectl get pvc,pv -n storage-demo           # Bound, PV pvc-<uid> created by the provisioner
# On a cloud cluster the provisioner would be the CSI driver, e.g. ebs.csi.aws.com (type: gp3)
# or pd.csi.storage.gke.io (type: pd-ssd). local-path does not enforce the 20Gi size.
