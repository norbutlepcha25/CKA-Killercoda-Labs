# Mock Exam 02 - Question 05 - API Server Debugging  (Troubleshooting | 9 min)
#
# The API server is slow. Audit logging is already enabled:
#   policy /etc/kubernetes/audit/policy.yaml, log /var/log/kubernetes/audit/audit.log
#
# Tasks (control plane node)
# 1. Save the last 50 lines of the kube-apiserver logs to /root/mock2/q05-apiserver.log
# 2. Save the ss/netstat line that shows kube-apiserver listening on port 6443 to /root/mock2/q05-listen.txt
# 3. Save the output of the API server's verbose readiness check (/readyz?verbose) to /root/mock2/q05-readyz.txt
# 4. Using the audit log, find the user that sends the most requests and write the username to
#    /root/mock2/q05-top-user.txt
# 5. Write the HTTP response code that user gets to /root/mock2/q05-code.txt
# 6. Stop that client: scale its Deployment to 0 replicas (find which one it is)
