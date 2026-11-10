# Mock Exam 03 - Question 13 - Gateway API Ingress  (Services & Networking | 7%)
#
# Team r500 wants to replace their Ingress (networking.k8s.io) with a Gateway API
# (gateway.networking.k8s.io) solution. The old Ingress is in /root/mock3/13/ingress.yaml.
#
# In Namespace project-r500, using the existing Gateway main:
# 1. Create HTTPRoute traffic-director that replicates the routes of the old Ingress
# 2. Extend it with path /auto, which forwards to the mobile backend if the User-Agent header is
#    exactly "mobile", and to the desktop backend otherwise
#
# The Gateway is reachable at the URL in /root/mock3/13/gateway-url (r500.gateway is in /etc/hosts).
# These must work:
#   U=$(cat /root/mock3/13/gateway-url)
#   curl $U/desktop        -> Web Desktop App
#   curl $U/mobile         -> Web Mobile App
#   curl $U/auto -H "User-Agent: mobile"   -> Web Mobile App
#   curl $U/auto           -> Web Desktop App
