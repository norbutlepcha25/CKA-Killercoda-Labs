# Mock Exam 02 - Question 14 - StorageClass and Dynamic Provisioning  (Storage | 8 min)
#
# The cluster runs the local-path provisioner (provisioner name rancher.io/local-path).
#
# Tasks
# 1. Create StorageClass ssd: provisioner rancher.io/local-path, reclaimPolicy Delete,
#    volumeBindingMode WaitForFirstConsumer
# 2. In namespace storage-demo create PVC my-ssd-claim: 20Gi, ReadWriteOnce, storageClassName ssd
# 3. Create pod app-using-ssd (image nginx:1.27) in storage-demo that mounts the claim at /data
# 4. Verify a PersistentVolume was created automatically and the claim is Bound
