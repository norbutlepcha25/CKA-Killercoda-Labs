kubectl -n project-tiger create deployment ds-important --image=httpd:2-alpine --dry-run=client -o yaml > 11.yaml
# edit: kind DaemonSet, remove replicas/strategy/status, set labels, add requests + toleration
cat > 11.yaml <<'YAML'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: ds-important
        image: httpd:2-alpine
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
YAML
kubectl apply -f 11.yaml
kubectl -n project-tiger get ds; kubectl -n project-tiger get pod -l id=ds-important -o wide
