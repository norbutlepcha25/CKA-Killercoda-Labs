kubectl create ns exercise-20
kubectl label ns exercise-20 pod-security.kubernetes.io/enforce=restricted
kubectl run rogue --image=nginx:1.28 --privileged -n exercise-20          # rejected (forbidden)

kubectl create ns exercise-20-baseline
kubectl label ns exercise-20-baseline pod-security.kubernetes.io/enforce=baseline
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: safe-pod
  namespace: exercise-20-baseline
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl run priv-pod --image=nginx:1.28 --privileged -n exercise-20-baseline   # rejected

kubectl create ns exercise-20-audit
kubectl label ns exercise-20-audit pod-security.kubernetes.io/audit=restricted pod-security.kubernetes.io/warn=restricted
kubectl run audit-pod --image=nginx:1.28 --privileged -n exercise-20-audit    # created, with "Warning: would violate PodSecurity restricted..."
kubectl get ns exercise-20 exercise-20-baseline exercise-20-audit --show-labels
