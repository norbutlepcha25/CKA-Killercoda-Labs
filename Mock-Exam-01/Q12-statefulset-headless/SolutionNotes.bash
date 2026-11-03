cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
  namespace: default
spec:
  clusterIP: None
  selector:
    app: database-cluster
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database-cluster
  namespace: default
spec:
  serviceName: database-cluster
  replicas: 3
  selector:
    matchLabels:
      app: database-cluster
  template:
    metadata:
      labels:
        app: database-cluster
    spec:
      containers:
      - name: postgres
        image: postgres:17-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: mockexam
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 10Gi
EOF
kubectl rollout status sts database-cluster
kubectl get pods -l app=database-cluster -o wide
kubectl get pvc                         # data-database-cluster-0/1/2, all Bound
kubectl exec database-cluster-1 -- nslookup database-cluster-0.database-cluster
# PVC names are <template name>-<pod name>. postgres needs POSTGRES_PASSWORD or it exits.
