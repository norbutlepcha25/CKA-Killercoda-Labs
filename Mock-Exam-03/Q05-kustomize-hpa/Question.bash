# Mock Exam 03 - Question 05 - Kustomize configure HPA Autoscaler  (Workloads / Kustomize | 8%)
#
# The application api-gateway used an external autoscaler, which is to be replaced by a
# HorizontalPodAutoscaler. It is deployed to Namespaces api-gateway-staging and api-gateway-prod with:
#   kubectl kustomize /root/mock3/5/api-gateway/staging | kubectl apply -f -
#   kubectl kustomize /root/mock3/5/api-gateway/prod    | kubectl apply -f -
#
# Using the Kustomize config in /root/mock3/5/api-gateway:
# 1. Remove the ConfigMap horizontal-scaling-config completely
# 2. Add an HPA named api-gateway for Deployment api-gateway: min 2, max 4 replicas,
#    scaling at 50% average CPU utilisation
# 3. In prod the HPA must allow max 6 replicas
# 4. Apply your changes for staging and prod so the cluster reflects them
