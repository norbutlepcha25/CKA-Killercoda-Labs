# Question 19 - Classic Ingress  (Services & Networking | Medium | 15 min)
#
# The lab setup installed the ingress-nginx controller (IngressClass nginx).
#
# Tasks
# 1. Create a namespace called exercise-19
# 2. Create two Deployments:
#    - web-app with image nginx:1.28 and 2 replicas, serving on port 80
#    - api-app with image nginx:1.28 and 2 replicas
# 3. Expose web-app with a ClusterIP service named web-service on port 80 (targetPort 80)
# 4. Expose api-app with a ClusterIP service named api-service on port 8080 (targetPort 80)
# 5. Create an Ingress named app-ingress (ingressClassName nginx) that routes:
#    - /    traffic to web-service:80
#    - /api traffic to api-service:8080
#    - Default backend (no matching path) points to web-service:80
# 6. Verify the Ingress was created and has an address assigned
# 7. Test path-based routing by describing the Ingress (check rules) and with curl via the controller NodePort
