kubectl patch configmap app-config -n config-demo -p '{"data":{"mode":"green"}}'
#   or: kubectl edit cm app-config -n config-demo
# Volume mounts (without subPath) are refreshed by the kubelet on its next sync - usually < 1 min.
P=$(kubectl get pod -n config-demo -l app=volume-app -o name)
sleep 60; kubectl exec -n config-demo $P -- cat /config/mode            # green, same pod
kubectl logs -n config-demo deploy/volume-app --tail=3
# Environment variables are fixed when the container starts - only a new pod gets the new value:
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # still blue
kubectl rollout restart deployment/env-app -n config-demo
kubectl rollout status deployment/env-app -n config-demo
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # green
# Never updated automatically: env vars, envFrom, and subPath mounts.
# Fully automatic restarts on change need a controller such as Stakater Reloader, or a config
# hash annotation in the pod template that changes whenever the ConfigMap changes.
