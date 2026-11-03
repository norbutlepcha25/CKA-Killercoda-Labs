kubectl get crd | grep -i database
kubectl get crd databases.example.com -o jsonpath='{.metadata.name}' > /root/mock2/q12-crd.txt
kubectl explain database.spec                     # fields: engine (postgres|mysql), version, storage
cat <<'EOF' | kubectl apply -f -
apiVersion: example.com/v1
kind: Database
metadata:
  name: prod-db
  namespace: crd-demo
spec:
  engine: postgres
  version: "15"          # quoted - the schema says string
  storage: 100Gi
EOF
kubectl get databases -n crd-demo                 # short name: kubectl get db -n crd-demo
# etcd keys: /registry/<group>/<plural>/<namespace>/<name>
# etcdctl from the etcd container (works even if etcdctl is not installed on the node):
ETCD=$(crictl ps --name etcd -q | head -1)
crictl exec $ETCD etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/example.com/databases/crd-demo/prod-db --keys-only | tee /root/mock2/q12-etcd.txt
kubectl delete database old-db -n crd-demo
kubectl get databases -n crd-demo
