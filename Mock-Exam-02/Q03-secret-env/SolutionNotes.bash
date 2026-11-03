kubectl create secret generic db-creds -n secrets-demo \
  --from-literal=username=dbuser --from-literal=password=secret123 --from-literal=database=appdb
# Quick way: one secretKeyRef per key, names upper-cased with the prefix
kubectl set env deployment/app-deploy -n secrets-demo --from=secret/db-creds --prefix=DB_
kubectl get deploy app-deploy -n secrets-demo -o yaml | grep -A4 'name: DB_'
# Same result in YAML (under the app container):
#   env:
#   - name: DB_USERNAME
#     valueFrom: {secretKeyRef: {name: db-creds, key: username}}
#   - name: DB_PASSWORD
#     valueFrom: {secretKeyRef: {name: db-creds, key: password}}
#   - name: DB_DATABASE
#     valueFrom: {secretKeyRef: {name: db-creds, key: database}}
kubectl rollout status deployment/app-deploy -n secrets-demo
kubectl exec deploy/app-deploy -n secrets-demo -- env | grep DB_
kubectl logs deploy/app-deploy -n secrets-demo                  # only "app started"
# Secrets are base64-encoded, not encrypted. Anyone allowed to exec into the pod or read the
# Secret can see the values - control that with RBAC (and encryption at rest for etcd).
