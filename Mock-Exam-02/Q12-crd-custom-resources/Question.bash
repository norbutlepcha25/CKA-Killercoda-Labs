# Mock Exam 02 - Question 12 - Custom Resource Definitions  (Cluster Architecture | 7 min)
#
# Your team installed a CRD for the kind Database.
#
# Tasks
# 1. Find the CRD and write its full name to /root/mock2/q12-crd.txt
# 2. In namespace crd-demo create a Database named prod-db with
#      spec.engine=postgres  spec.version="15"  spec.storage=100Gi
# 3. Show that prod-db is stored in etcd: save the output of an etcdctl get for its key
#    (--keys-only is enough) to /root/mock2/q12-etcd.txt
# 4. Delete the Database old-db in crd-demo
