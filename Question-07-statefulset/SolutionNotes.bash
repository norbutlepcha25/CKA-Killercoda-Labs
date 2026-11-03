cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    name: mysql
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF
kubectl get pods -l app=mysql -w            # mysql-0, mysql-1, mysql-2 in order
kubectl get pvc                             # data-mysql-0/1/2
kubectl run debug --image=busybox:1.36 --rm -it --restart=Never -- nslookup mysql-0.mysql.default.svc.cluster.local
kubectl delete pod mysql-1 && kubectl get pods -l app=mysql   # mysql-1 comes back
kubectl scale statefulset mysql --replicas=4
kubectl scale statefulset mysql --replicas=2
kubectl delete statefulset mysql
kubectl get pvc                             # PVCs are still there
