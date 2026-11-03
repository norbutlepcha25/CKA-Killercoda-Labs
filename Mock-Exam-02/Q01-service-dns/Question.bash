# Mock Exam 02 - Question 01 - Service Discovery and DNS  (Services & Networking | 6 min)
#
# Service web-ui in namespace frontend exposes port 3000. An application in namespace backend
# must call it by DNS.
#
# Tasks
# 1. Write the fully qualified DNS name of the service to /root/mock2/q01-fqdn.txt
# 2. Create pod dns-test in namespace backend (image busybox:1.37, command: sleep 3600)
# 3. From dns-test, resolve the service name with nslookup and write the IP it resolves to
#    into /root/mock2/q01-ip.txt
# 4. From dns-test, fetch http://web-ui.frontend:3000 and check the answer
