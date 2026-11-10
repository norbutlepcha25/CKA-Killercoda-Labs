kubectl -n project-jaguar create deployment deploy-important --image=nginx:1-alpine --replicas=3 --dry-run=client -o yaml > 12.yaml
cat > 12.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-jaguar
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      containers:
      - name: container1
        image: nginx:1-alpine
      - name: container2
        image: registry.k8s.io/pause:3.10
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: id
                operator: In
                values: ["very-important"]
            topologyKey: kubernetes.io/hostname
      # alternative to affinity:
      # topologySpreadConstraints:
      # - maxSkew: 1
      #   topologyKey: kubernetes.io/hostname
      #   whenUnsatisfiable: DoNotSchedule
      #   labelSelector:
      #     matchLabels:
      #       id: very-important
YAML
kubectl apply -f 12.yaml
kubectl -n project-jaguar get pod -o wide -l id=very-important   # one per schedulable node, rest Pending
kubectl -n project-jaguar describe pod <pending-pod> | grep FailedScheduling
