#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node)
banner "Validating Question 11"
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  eq "node $n Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $n)" True
done
eq "kubelet enabled on $W (survives reboot)" "$(on_node "$W" 'systemctl is-enabled kubelet' 2>/dev/null)" enabled
eq "kubelet active on $W" "$(on_node "$W" 'systemctl is-active kubelet' 2>/dev/null)" active
CF=$(jp '{.data.Corefile}' cm coredns -n kube-system)
if echo "$CF" | grep -q 'kubernetess'; then fail "CoreDNS Corefile still contains the typo 'kubernetess'"
elif echo "$CF" | grep -q 'kubernetes cluster.local'; then pass "CoreDNS Corefile has a valid kubernetes plugin block"
else fail "CoreDNS Corefile has no 'kubernetes cluster.local' block"; fi
RR=$(jp '{.status.readyReplicas}' deploy coredns -n kube-system)
if [ "${RR:-0}" -ge 1 ]; then pass "CoreDNS has $RR ready replica(s)"; else fail "CoreDNS has no ready replicas"; fi
nonempty "kube-dns service has endpoints" "$(jp '{.subsets[*].addresses[*].ip}' endpoints kube-dns -n kube-system)"
kubectl delete pod test-dns --ignore-not-found --now >/dev/null 2>&1
if kubectl run test-dns --image=busybox:1.36 --restart=Never --rm -i --quiet --command -- nslookup kubernetes.default.svc.cluster.local 2>/dev/null | grep -q 'Name:'; then
  pass "DNS resolution works from a pod"; else fail "DNS resolution from a pod failed"; fi
if kubectl get ds kube-proxy -n kube-system >/dev/null 2>&1; then
  eq "kube-proxy running on all nodes" "$(jp '{.status.numberReady}' ds kube-proxy -n kube-system)" "$(jp '{.status.desiredNumberScheduled}' ds kube-proxy -n kube-system)"
fi
summary
