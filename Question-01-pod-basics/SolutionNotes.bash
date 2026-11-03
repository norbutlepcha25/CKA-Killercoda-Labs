kubectl create ns exercise-01
kubectl run web -n exercise-01 --image=nginx:1.27 --labels=app=web,tier=frontend --dry-run=client -o yaml > pod.yaml
# edit pod.yaml and add the resources block - the finished file:
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: exercise-01
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: web
    image: nginx:1.27
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "250m"
EOF
kubectl apply -f pod.yaml
kubectl get pod web -n exercise-01 --show-labels
kubectl get pod web -n exercise-01 -o wide
kubectl label pod web -n exercise-01 version=v1
kubectl label pod web -n exercise-01 tier-
