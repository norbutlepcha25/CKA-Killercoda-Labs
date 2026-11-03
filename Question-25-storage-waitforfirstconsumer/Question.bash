# Question 25 - Storage with WaitForFirstConsumer Binding  (Storage | Hard | 20 min)
#
# The lab setup created the directory /tmp/k8s-pv on every node.
#
# Tasks
# 1. Create a namespace called exercise-25
# 2. Create a StorageClass named local-storage with:
#    - Provisioner: kubernetes.io/no-provisioner (local volumes)
#    - Binding mode: WaitForFirstConsumer
# 3. Create a PersistentVolume named local-pv-1 with:
#    - Size: 1Gi, AccessMode: ReadWriteOnce, StorageClassName: local-storage
#    - Local path: /tmp/k8s-pv, with nodeAffinity to node01
# 4. Create a PersistentVolumeClaim named local-pvc (1Gi, storageClassName local-storage) in exercise-25
# 5. Observe: the PVC stays Pending (not Bound) - why?
# 6. Create a Pod named app-pod (busybox:1.36, sleep 3600) that mounts the PVC at /data
# 7. Observe: the PVC becomes Bound and the pod schedules on the node where the PV exists
# 8. Verify persistence by writing /data/test.txt from the pod
