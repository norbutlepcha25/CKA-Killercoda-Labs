kubectl create ns exercise-16
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-app
  namespace: exercise-16
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-app
  template:
    metadata:
      labels:
        app: load-app
    spec:
      containers:
      - name: app
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "50m"
          limits:
            cpu: "100m"
EOF
kubectl expose deployment load-app -n exercise-16 --name=load-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: load-app
  namespace: exercise-16
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF
# (imperative alternative: kubectl autoscale deployment load-app -n exercise-16 --cpu-percent=50 --min=1 --max=5)
kubectl get hpa load-app -n exercise-16 -o yaml | grep -A4 target:
# terminal 1 - generate load:
kubectl run load-gen -n exercise-16 --image=busybox:1.36 --rm -it --restart=Never -- sh -c "while true; do wget -q -O- http://load-svc; done"
# terminal 2 - watch:
kubectl get hpa -n exercise-16 -w
# Ctrl+C the load, wait ~5 min for scale-down
