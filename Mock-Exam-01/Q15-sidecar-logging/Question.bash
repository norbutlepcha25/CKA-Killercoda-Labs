# Mock Exam 01 - Question 15 - Multi-Container Pod with Sidecar  (Workloads & Scheduling | 8 min)
#
# Tasks (namespace default)
# Create pod app-with-logger with:
# 1. Container nginx, image nginx:1.28
# 2. Container logger, image busybox:1.37, that follows the nginx access log:  tail -F /logs/access.log
# 3. An emptyDir volume shared by both: mounted at /var/log/nginx in nginx and at /logs in logger
# 4. Both containers keep running without restarts, and requests to nginx show up in
#    kubectl logs app-with-logger -c logger
