kubectl autoscale deployment web-app -n production --min=2 --max=10 --cpu-percent=70
# (kubectl 1.35 may print a deprecation note for --cpu-percent; the result is the same autoscaling/v2 object)
kubectl get hpa web-app -n production          # TARGETS cpu: 0%/70% after ~30-60s
kubectl describe hpa web-app -n production
# YAML version:
# apiVersion: autoscaling/v2
# kind: HorizontalPodAutoscaler
# metadata: {name: web-app, namespace: production}
# spec:
#   scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web-app}
#   minReplicas: 2
#   maxReplicas: 10
#   metrics:
#   - type: Resource
#     resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
# Utilization is measured against the pods' CPU *requests* - without requests the HPA shows <unknown>.
