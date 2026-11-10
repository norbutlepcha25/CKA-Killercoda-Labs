# Mock Exam 03 - Question 20 - Preview: Change Service CIDR  (Services & Networking | 7%)
#
# 1. Create Pod check-ip in Namespace default, image httpd:2-alpine
# 2. Expose it on port 80 as ClusterIP Service check-ip-service. Note the Service IP
# 3. Change the Service CIDR of the cluster to 11.96.0.0/12
# 4. Create a second Service check-ip-service2 for the same Pod - it must get an IP from the
#    new range
#
# Set up on demand (./mock.sh 3 20): this restarts the API server and controller manager.
# Do it last; a fresh Killercoda session is recommended afterwards.
