# Question 07 - StatefulSet  (Workloads & Scheduling | Medium | 15 min)
#
# Work in the default namespace.
#
# Tasks
# 1. Create a headless Service named mysql (port 3306, selector app=mysql) for the StatefulSet
# 2. Create a StatefulSet named mysql with 3 replicas using the nginx:1.28 image
#    - serviceName: mysql, label app=mysql, containerPort 3306 named mysql
#    - volumeClaimTemplate named data (ReadWriteOnce, 1Gi) mounted at /data
# 3. Verify pods start in order (mysql-0 first, then mysql-1, then mysql-2)
# 4. Verify each pod has a PersistentVolumeClaim attached
# 5. Delete a pod and observe it respawn with the same name and storage
# 6. Scale the StatefulSet up and down using kubectl scale
# 7. Delete the StatefulSet and verify the PVCs persist (data survives)
