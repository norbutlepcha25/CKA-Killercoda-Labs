# Question 15 - Gateway API: Gateway and HTTPRoute  (Services & Networking | Medium | 20 min)
#
# The lab setup installed Envoy Gateway and a GatewayClass named eg.
#
# Tasks
# 1. Create a namespace called exercise-15
# 2. Verify a GatewayClass exists in the cluster
# 3. Create a Gateway named web-gateway in namespace exercise-15:
#    - Reference the existing GatewayClass
#    - Listen on port 80, protocol HTTP
# 4. Create a Deployment named web with image nginx:1.28 and 2 replicas
# 5. Expose it with a ClusterIP Service named web-svc on port 80
# 6. Create an HTTPRoute named web-route that:
#    - References web-gateway as the parent
#    - Matches path prefix /
#    - Routes to web-svc on port 80
# 7. Verify the Gateway status shows Programmed: True
# 8. Verify the HTTPRoute is attached to the Gateway
# Bonus: send a request through the gateway (Envoy is exposed as a NodePort Service in envoy-gateway-system)
