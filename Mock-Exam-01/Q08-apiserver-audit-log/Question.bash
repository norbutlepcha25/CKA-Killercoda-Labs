# Mock Exam 01 - Question 08 - API Server Audit Logs  (Troubleshooting | 10 min)
#
# Somebody keeps reading ConfigMaps in namespace default. Use audit logging to find out who.
#
# Tasks
# 1. Enable audit logging on the kube-apiserver (control plane node):
#    - audit policy file /etc/kubernetes/audit/policy.yaml that logs ConfigMap requests at level
#      Metadata (or higher). Everything else may be logged at level None.
#    - audit log file /var/log/kubernetes/audit/audit.log
#    - --audit-log-maxbackup=2 and --audit-log-maxsize=10
# 2. Wait for new requests. Find the ServiceAccount that keeps listing ConfigMaps in namespace
#    default and write its audit username to /root/mock1/q08-user.txt
#    (kubelets also watch ConfigMaps - ignore system:node:* users)
# 3. Write the HTTP response code those requests get to /root/mock1/q08-code.txt
# 4. Write the requestReceivedTimestamp of one of those requests to /root/mock1/q08-time.txt
#
# Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
