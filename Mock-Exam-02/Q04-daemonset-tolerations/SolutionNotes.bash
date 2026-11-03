kubectl describe node controlplane | grep Taints        # node-role.kubernetes.io/control-plane:NoSchedule
kubectl get ds monitoring-agent -n monitoring           # DESIRED = number of worker nodes only
kubectl patch ds monitoring-agent -n monitoring --type=json -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}]'
# or kubectl edit ds monitoring-agent -n monitoring and add under spec.template.spec:
#   tolerations:
#   - key: node-role.kubernetes.io/control-plane
#     operator: Exists
#     effect: NoSchedule
kubectl rollout status ds monitoring-agent -n monitoring
kubectl get pods -n monitoring -o wide                  # one pod per node, incl. controlplane
# (The original exercise used datadog/agent:latest - a >1 GB image that also needs an API key,
#  so this lab uses busybox.)
