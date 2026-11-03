# Question 30 - TLS Configuration Update  (Security | Hard | 20 min)
#
# The lab setup created, in namespace exercise-30:
#   Deployment tls-web (nginx) - Service tls-web (port 443) - ConfigMap tls-config (nginx.conf) - Secret tls-web-cert
# The service currently supports only TLS 1.3.
#
# Tasks
# 1. Find the TLS setting in the ConfigMap that is mounted into the Deployment
# 2. Add support for TLS 1.2 (both TLSv1.2 and TLSv1.3 must be enabled)
# 3. Restart the Deployment so the new configuration is used
# 4. Verify the service accepts TLS 1.2 connections:
#      curl -vk --tlsv1.2 --tls-max 1.2 https://<service-ip>
#      or: echo | openssl s_client -connect <service-ip>:443 -tls1_2
# 5. Verify TLS 1.3 still works:  curl -vk --tlsv1.3 https://<service-ip>
