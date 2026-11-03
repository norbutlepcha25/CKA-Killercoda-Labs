kubectl create ns exercise-06
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: exercise-06
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
EOF
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="initial deploy nginx:1.28"
kubectl set image deployment/webapp nginx=nginx:1.29 -n exercise-06
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="update to nginx:1.29" --overwrite
kubectl rollout status deployment/webapp -n exercise-06
kubectl rollout history deployment/webapp -n exercise-06
kubectl rollout undo deployment/webapp -n exercise-06
kubectl get deploy webapp -n exercise-06 -o jsonpath='{.spec.template.spec.containers[0].image}'   # nginx:1.28
