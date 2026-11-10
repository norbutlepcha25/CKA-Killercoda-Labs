# Mock Exam 03 - Question 06 - Storage, PV, PVC, Pod volume  (Storage | 8%)
#
# 1. Create PersistentVolume safari-pv: capacity 2Gi, accessMode ReadWriteOnce,
#    hostPath /Volumes/Data, no storageClassName
# 2. Create PersistentVolumeClaim safari-pvc in Namespace project-t230: request 2Gi,
#    accessMode ReadWriteOnce, no storage class. It must be Bound to safari-pv
# 3. Create Deployment safari in Namespace project-t230 (image httpd:2-alpine) that mounts
#    the volume at /tmp/safari-data
#
# Killercoda hint: if the cluster has a default StorageClass, a PVC without storageClassName
# gets the default class added automatically and will not bind to safari-pv. In that case
# set  storageClassName: ""  on the PVC (that means "no class").
