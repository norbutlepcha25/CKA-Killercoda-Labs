mkdir -p /root/kustomize-lab/base /root/kustomize-lab/overlays/staging
cd /root/kustomize-lab
cat <<'EOF' > base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
EOF
cat <<'EOF' > base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  selector:
    app: app
  ports:
  - port: 80
    targetPort: 80
EOF
cat <<'EOF' > base/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF
cat <<'EOF' > overlays/staging/kustomization.yaml
resources:
- ../../base
namespace: exercise-14
labels:
- pairs:
    env: staging
  includeSelectors: true
  includeTemplates: true
replicas:
- name: app
  count: 3
EOF
kubectl create ns exercise-14
kubectl kustomize overlays/staging          # preview
kubectl apply -k overlays/staging
kubectl get pods -n exercise-14 -l env=staging
# (commonLabels: {env: staging} also works but is deprecated)
