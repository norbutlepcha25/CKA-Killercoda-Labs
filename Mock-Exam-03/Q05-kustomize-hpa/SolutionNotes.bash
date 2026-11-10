cd /root/mock3/5/api-gateway
kubectl kustomize staging          # see what base + overlay produce
# 1. delete the ConfigMap document from base/api-gateway.yaml AND from the staging/ and prod/ patches
#    (a patch for a resource that no longer exists makes the build fail)
# 2. add to base/api-gateway.yaml (no namespace - the overlays set it):
cat >> base/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
YAML
# 3. add to prod/api-gateway.yaml:
cat >> prod/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6
YAML
kubectl kustomize staging | grep -B5 maxReplicas
kubectl kustomize prod | grep -B5 maxReplicas
# 4. apply - kustomize keeps no state, so the old ConfigMaps must be deleted by hand
kubectl kustomize staging | kubectl apply -f -
kubectl kustomize prod | kubectl apply -f -
kubectl -n api-gateway-staging delete cm horizontal-scaling-config
kubectl -n api-gateway-prod delete cm horizontal-scaling-config
# Optional: remove "replicas: 1" from the Deployment so re-applying does not fight the HPA.
