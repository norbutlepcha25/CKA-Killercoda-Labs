grep staticPodPath /var/lib/kubelet/config.yaml      # /etc/kubernetes/manifests
cat <<'EOF' > /etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    app: static-web
spec:
  containers:
  - name: web
    image: nginx:1.27
    ports:
    - containerPort: 80
EOF
kubectl get pods | grep static-web                   # static-web-controlplane
kubectl delete pod static-web-controlplane           # it comes back (mirror pod)
rm /etc/kubernetes/manifests/static-web.yaml
kubectl get pods | grep static-web                   # gone
