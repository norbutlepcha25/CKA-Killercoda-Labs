kubectl -n production logs app-frontend                 # ERROR: /etc/app/config.yaml not found
kubectl create configmap app-config -n production \
  --from-literal=config.yaml='database_host: postgres.production.svc.cluster.local'

# Add the volume + mount to the manifest. The finished file:
cat <<'EOF' > /root/mock1/app-frontend.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
  labels:
    app: app-frontend
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "if [ ! -f /etc/app/config.yaml ]; then echo 'ERROR: /etc/app/config.yaml not found'; exit 1; fi; echo 'config loaded:'; cat /etc/app/config.yaml; exec sleep 3600"]
    volumeMounts:
    - name: config
      mountPath: /etc/app            # the key config.yaml becomes /etc/app/config.yaml
  volumes:
  - name: config
    configMap:
      name: app-config
      items:
      - key: config.yaml
        path: config.yaml
EOF
# A running pod can't get new volumes - recreate it
kubectl replace --force -f /root/mock1/app-frontend.yaml
kubectl get pod app-frontend -n production
kubectl exec app-frontend -n production -- cat /etc/app/config.yaml
# Alternative: mountPath /etc/app/config.yaml + subPath config.yaml mounts only that one file
# (but subPath mounts do not receive ConfigMap updates).
