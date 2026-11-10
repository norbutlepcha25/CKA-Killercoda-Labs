#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 20"
eq "Pod check-ip image" "$(jp '{.spec.containers[0].image}' pod check-ip -n default)" httpd:2-alpine
check "kube-apiserver uses 11.96.0.0/12" grep -q -- '--service-cluster-ip-range=11.96.0.0/12' /etc/kubernetes/manifests/kube-apiserver.yaml
check "kube-controller-manager uses 11.96.0.0/12" grep -q -- '--service-cluster-ip-range=11.96.0.0/12' /etc/kubernetes/manifests/kube-controller-manager.yaml
if kubectl get servicecidr -o jsonpath='{.items[*].spec.cidrs[*]}' 2>/dev/null | grep -qw 11.96.0.0/12; then pass "a ServiceCIDR for 11.96.0.0/12 exists"; else fail "no ServiceCIDR with 11.96.0.0/12"; fi
IP1=$(jp '{.spec.clusterIP}' svc check-ip-service -n default); IP2=$(jp '{.spec.clusterIP}' svc check-ip-service2 -n default)
check "check-ip-service has an IP from the old range 10.96.0.0/12 ($IP1)" in_cidr12 "$IP1" 10
check "check-ip-service2 has an IP from 11.96.0.0/12 ($IP2)" in_cidr12 "$IP2" 11
PIP=$(jp '{.status.podIP}' pod check-ip -n default)
for s in check-ip-service check-ip-service2; do
  if [ -n "$PIP" ] && kubectl get endpointslice -n default -l kubernetes.io/service-name=$s -o jsonpath='{.items[*].endpoints[*].addresses[*]}' | grep -qw "$PIP"; then pass "$s points to Pod check-ip"; else fail "$s does not point to Pod check-ip"; fi
done
summary
