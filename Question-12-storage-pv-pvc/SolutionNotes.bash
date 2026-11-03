kubectl create ns exercise-12
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data/exercise-12
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: exercise-12
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi
EOF
kubectl get pvc my-pvc -n exercise-12          # Bound
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-consumer
  namespace: exercise-12
spec:
  nodeName: node01               # keeps the pod on the same node so the hostPath data is there
  containers:
  - name: consumer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
EOF
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- sh -c 'echo "data persists" > /data/test.txt'
kubectl delete pod storage-consumer -n exercise-12 && kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- cat /data/test.txt   # data persists
kubectl delete pod storage-consumer -n exercise-12
kubectl delete pvc my-pvc -n exercise-12
kubectl get pv my-pv                            # Released
# Note: hostPath is node-local. Pinning the pod (nodeName/nodeSelector) keeps both pods on one node.
