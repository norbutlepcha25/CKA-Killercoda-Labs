#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
W=$(worker_node)
banner "Validating Mock Exam 01 - Question 07 (node $W)"
if on_node "$W" "cat /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml /etc/default/kubelet 2>/dev/null" | grep -q 'cri-dockerd.sock'; then pass "kubelet configured with the cri-dockerd socket"; else fail "kubelet on $W is not pointed at cri-dockerd.sock"; fi
eq "node $W Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $W)" True
RT=$(jp '{.status.nodeInfo.containerRuntimeVersion}' node $W)
if echo "$RT" | grep -q '^docker://'; then pass "node runtime is $RT"; else fail "node runtime is '$RT' (expected docker://...)"; fi
kubectl delete pod runtime-check --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
kubectl run runtime-check --image=busybox:1.37 --restart=Never --overrides="{\"spec\":{\"nodeName\":\"$W\"}}" -- sleep 300 >/dev/null 2>&1
if kubectl wait --for=condition=Ready pod/runtime-check --timeout=90s >/dev/null 2>&1; then pass "test pod runs on $W"; else fail "test pod on $W did not start"; fi
kubectl delete pod runtime-check --force --grace-period=0 --ignore-not-found >/dev/null 2>&1
summary
