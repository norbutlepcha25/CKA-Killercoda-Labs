cat /root/helm-charts/monitoring/values.yaml          # see the value names
helm install monitoring-stack /root/helm-charts/monitoring \
  -n monitoring --create-namespace \
  --set replica_count=3 \
  --set storage_size=50Gi \
  --set persistence=true
helm list -n monitoring
helm get values monitoring-stack -n monitoring
kubectl get deploy,pvc -n monitoring
# Same thing with a values file:  helm install ... -f my-values.yaml
# --set turns "true" into a boolean; use --set-string if you ever need the string "true".
