kubectl create ns exercise-04
kubectl create sa dev-sa -n exercise-04
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-manager
  namespace: exercise-04
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "delete"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
EOF
kubectl create rolebinding dev-pod-access -n exercise-04 --role=pod-manager --serviceaccount=exercise-04:dev-sa
AS=system:serviceaccount:exercise-04:dev-sa
kubectl auth can-i list pods -n exercise-04 --as=$AS       # yes
kubectl auth can-i list pods -n default --as=$AS           # no
kubectl create clusterrole node-viewer --verb=get,list --resource=nodes
kubectl create clusterrolebinding dev-node-access --clusterrole=node-viewer --serviceaccount=exercise-04:dev-sa
kubectl auth can-i list nodes --as=$AS                     # yes
kubectl auth can-i delete deployments -n exercise-04 --as=$AS   # no - Role has no apps/deployments rule
kubectl auth can-i --list -n exercise-04 --as=$AS
