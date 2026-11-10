# Mock Exam 03 - Question 16 - Update CoreDNS Configuration  (Services & Networking | 5%)
#
# 1. Back up the current CoreDNS configuration YAML to /root/mock3/16/coredns_backup.yaml.
#    You must be able to restore quickly from it.
# 2. Change the CoreDNS configuration so that SERVICE.NAMESPACE.custom-domain resolves the same as
#    SERVICE.NAMESPACE.cluster.local (in addition to it)
#
# Test from a Pod with image busybox:1 - both must return an IP address:
#   nslookup kubernetes.default.svc.cluster.local
#   nslookup kubernetes.default.svc.custom-domain
