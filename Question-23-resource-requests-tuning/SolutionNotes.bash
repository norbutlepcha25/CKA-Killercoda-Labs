kubectl get pods -n exercise-23                         # some Pending
kubectl describe pod -n exercise-23 <pending-pod>       # 0/2 nodes available: Insufficient cpu
kubectl describe nodes | grep -A8 -E "Allocatable|Allocated resources"
# Example: node01 allocatable cpu 1000m, already requested 250m -> 750m free
#          3 pods across the nodes with ~20% headroom -> about 150m-200m CPU and 128Mi memory each
kubectl set resources deployment web -n exercise-23 --requests=cpu=150m,memory=128Mi
kubectl rollout status deployment web -n exercise-23
kubectl get pods -n exercise-23 -o wide                 # 3/3 Running
cat <<'EOF' > /root/exercise-23-calculation.txt
node allocatable cpu / memory, minus requests already allocated, divided by 3 replicas,
minus ~20% headroom -> requests cpu=150m memory=128Mi
EOF
