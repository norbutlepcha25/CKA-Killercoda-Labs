# Mock Exam 03 - Question 09 - Contact K8s API from inside Pod  (Security | 6%)
#
# ServiceAccount secret-reader exists in Namespace project-swan.
# Create Pod api-contact (image nginx:1-alpine) in that Namespace that uses this ServiceAccount.
#
# Exec into the Pod and use curl to query all Secrets (cluster-wide) from the Kubernetes API.
# Write the result into /root/mock3/9/result.json on controlplane.
