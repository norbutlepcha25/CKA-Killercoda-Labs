# Mock Exam 01 - Question 12 - StatefulSet with Persistent Storage  (Workloads & Storage | 10 min)
#
# Tasks (namespace default)
# 1. Create a headless Service database-cluster exposing port 5432, selecting app=database-cluster
# 2. Create a StatefulSet database-cluster:
#    - 3 replicas, serviceName database-cluster, pod label app=database-cluster
#    - container postgres, image postgres:17-alpine, port 5432, env POSTGRES_PASSWORD=mockexam
#    - a volumeClaimTemplate named data: 10Gi, ReadWriteOnce, storageClassName local-path,
#      mounted at /var/lib/postgresql/data
# 3. Verify all 3 pods are Ready, each has its own Bound PVC, and that the stable DNS name
#    database-cluster-0.database-cluster resolves from another pod
