# Mock Exam 01 - Question 04 - Persistent Volume Configuration  (Storage | 10 min)
#
# Deployment db-app in namespace databases needs persistent storage that several pods can use
# at the same time. This cluster has no dynamic SSD provisioner, so you provision it statically.
#
# Tasks
# 1. Create StorageClass fast-ssd with provisioner kubernetes.io/no-provisioner
# 2. Create PersistentVolume db-pv: 5Gi, access mode ReadWriteMany, storageClassName fast-ssd,
#    hostPath /mnt/fast-ssd
# 3. Create PersistentVolumeClaim db-storage in namespace databases: 5Gi, ReadWriteMany,
#    storageClassName fast-ssd - it must be Bound to db-pv
# 4. Mount the claim at /data in the db-app containers and make sure the rollout completes
