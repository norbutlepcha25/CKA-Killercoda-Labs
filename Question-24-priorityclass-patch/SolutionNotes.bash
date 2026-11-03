kubectl create ns exercise-24
kubectl create priorityclass high-priority --value=999999 --description="Critical workload"
kubectl create deployment critical-app -n exercise-24 --image=busybox:1.36 --replicas=1 -- sleep 3600
kubectl patch deployment critical-app -n exercise-24 -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
# JSON-patch alternative:
# kubectl patch deployment critical-app -n exercise-24 --type=json -p='[{"op":"add","path":"/spec/template/spec/priorityClassName","value":"high-priority"}]'
kubectl rollout status deployment critical-app -n exercise-24
kubectl get pod -n exercise-24 -l app=critical-app -o jsonpath='{.items[0].spec.priorityClassName}'
kubectl create deployment normal-app -n exercise-24 --image=busybox:1.36 -- sleep 3600
kubectl get pod -n exercise-24 -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
