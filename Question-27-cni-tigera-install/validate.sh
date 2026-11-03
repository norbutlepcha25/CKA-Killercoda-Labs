#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 27"
CIDR=$(kubectl -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{.items[0].spec.containers[0].command}' 2>/dev/null | tr ',' '\n' | grep cluster-cidr | cut -d= -f2 | tr -d '"]')
eq "tigera-operator deployment available" "$(jp '{.status.conditions[?(@.type=="Available")].status}' deploy tigera-operator -n tigera-operator)" True
check "Installation 'default' exists" kubectl get installation default
eq "IP pool CIDR matches cluster CIDR ($CIDR)" "$(jp '{.spec.calicoNetwork.ipPools[0].cidr}' installation default)" "$CIDR"
eq "tigerastatus calico Available" "$(jp '{.status.conditions[?(@.type=="Available")].status}' tigerastatus calico)" True
eq "calico-node ready on all nodes" "$(jp '{.status.numberReady}' ds calico-node -n calico-system)" "$(kubectl get nodes --no-headers | wc -l)"
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  eq "node $n Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $n)" True
done
OLD=$(kubectl get ds -n kube-system -o name | grep -E 'canal|flannel|cilium|weave')
if [ -z "$OLD" ]; then pass "no other CNI DaemonSet left"; else fail "old CNI still present: $OLD"; fi
CP=$(cp_node); W=$(worker_node)
kubectl delete pod cni-test-a cni-test-b --ignore-not-found --now >/dev/null 2>&1
kubectl run cni-test-a --image=busybox:1.36 --restart=Never --overrides="{\"spec\":{\"nodeName\":\"$CP\",\"tolerations\":[{\"operator\":\"Exists\"}]}}" -- sleep 300 >/dev/null 2>&1
kubectl run cni-test-b --image=busybox:1.36 --restart=Never --overrides="{\"spec\":{\"nodeName\":\"$W\"}}" -- sleep 300 >/dev/null 2>&1
kubectl wait --for=condition=Ready pod/cni-test-a pod/cni-test-b --timeout=90s >/dev/null 2>&1
BIP=$(jp '{.status.podIP}' pod cni-test-b)
if [ -n "$BIP" ] && kubectl exec cni-test-a -- ping -c2 -W2 "$BIP" >/dev/null 2>&1; then pass "pod on $CP can reach pod on $W ($BIP)"; else fail "cross-node pod connectivity failed"; fi
kubectl delete pod cni-test-a cni-test-b --now >/dev/null 2>&1
summary
