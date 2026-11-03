cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-workload
value: 1000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Critical workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: standard-workload
value: 100
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Standard workloads"
EOF
for p in critical-pod-1 critical-pod-2; do
  kubectl run $p -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"critical-workload"}}'
done
kubectl run standard-pod -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"standard-workload"}}'
kubectl get pods -n priority-demo -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority
echo standard-pod > /root/mock2/q07-first-evicted.txt
# Two different mechanisms:
# - Preemption (scheduler): a pending higher-priority pod may evict lower-priority pods to fit.
#   preemptionPolicy: Never = the pod waits in the queue but never preempts others.
# - Node-pressure eviction (kubelet): ranks pods by (1) usage above requests, (2) priority,
#   (3) usage relative to requests. All three exceed their requests here, so the lowest
#   priority pod - standard-pod - goes first.
# Setting globalDefault: true would give every new pod without a class that priority - avoid it here.
