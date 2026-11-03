kubectl create ns exercise-25
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  local:
    path: /tmp/k8s-pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values: ["node01"]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: exercise-25
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
EOF
kubectl get pvc -n exercise-25      # Pending - WaitForFirstConsumer delays binding until a pod uses it
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: exercise-25
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: local-pvc
EOF
kubectl get pvc -n exercise-25 -w   # Bound
kubectl wait --for=condition=Ready pod/app-pod -n exercise-25
kubectl get pod app-pod -n exercise-25 -o wide    # on node01
kubectl exec app-pod -n exercise-25 -- sh -c 'echo "test data" > /data/test.txt'
kubectl exec app-pod -n exercise-25 -- cat /data/test.txt
