# Question 14 - Kustomize: Base and Overlay  (Cluster Architecture | Medium | 15 min)
#
# Tasks
# 1. Create this directory structure under /root:
#      /root/kustomize-lab/
#        base/
#          deployment.yaml
#          service.yaml
#          kustomization.yaml
#        overlays/
#          staging/
#            kustomization.yaml
# 2. In the base:
#    - A Deployment named app with image nginx:1.27 and 1 replica
#    - A ClusterIP Service named app-svc on port 80
#    - A kustomization.yaml listing both resources
# 3. In the staging overlay:
#    - Set the namespace to exercise-14
#    - Patch replicas to 3
#    - Add a common label env: staging
# 4. Create namespace exercise-14
# 5. Apply the staging overlay with kubectl apply -k
# 6. Verify 3 pods are running in namespace exercise-14 with label env=staging
