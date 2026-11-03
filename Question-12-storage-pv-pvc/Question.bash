# Question 12 - Storage: PV, PVC and Pod  (Storage | Medium | 15 min)
#
# Tasks
# 1. Create a namespace called exercise-12
# 2. Create a PersistentVolume named my-pv with:
#    - Capacity: 1Gi
#    - AccessMode: ReadWriteOnce
#    - StorageClass: manual
#    - hostPath: /data/exercise-12
#    - Reclaim policy: Retain
# 3. Create a PersistentVolumeClaim named my-pvc in namespace exercise-12:
#    - Request: 500Mi
#    - AccessMode: ReadWriteOnce
#    - StorageClass: manual
# 4. Create a pod named storage-consumer (busybox, sleep 3600) that mounts my-pvc at /data
# 5. Verify:
#    - The PVC is Bound to the PV
#    - The Pod is Running (not stuck Pending)
# 6. Write a test file /data/test.txt inside the mounted volume from the Pod
# 7. Delete the pod, create a new pod with the same PVC, and verify the file persists
# 8. Delete the pod and the PVC and check the PV status (should be Released, not Available, because the policy is Retain)
