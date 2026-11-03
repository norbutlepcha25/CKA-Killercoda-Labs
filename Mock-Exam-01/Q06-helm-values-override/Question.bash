# Mock Exam 01 - Question 06 - Helm Chart Deployment  (Cluster Architecture | 8 min)
#
# A local Helm chart named monitoring is in /root/helm-charts/monitoring.
#
# Tasks
# 1. Install the chart as release monitoring-stack in namespace monitoring (create the namespace
#    if it doesn't exist), overriding these chart values:
#      replica_count = 3
#      storage_size  = 50Gi
#      persistence   = true   (a boolean)
# 2. Verify the release is deployed and the Deployment has 3 ready replicas
