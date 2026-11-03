cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logger
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:1.28
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  - name: logger
    image: busybox:1.37
    command: ["sh", "-c", "tail -F /logs/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /logs
  volumes:
  - name: logs
    emptyDir: {}
EOF
kubectl get pod app-with-logger
kubectl exec app-with-logger -c nginx -- curl -s localhost >/dev/null
kubectl logs app-with-logger -c logger
# The nginx image links access.log to /dev/stdout; mounting the emptyDir over /var/log/nginx
# replaces those links, so nginx writes real files the sidecar can read.
# tail -F (capital F) keeps retrying if the file doesn't exist yet - tail -f would exit and crash-loop.
# A native sidecar (initContainers + restartPolicy: Always) is fine too.
