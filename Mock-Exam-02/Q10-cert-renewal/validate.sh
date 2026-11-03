#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 10"
OLD=$(date -d "$(cat /root/.cka-lab/mock2-q10-old-enddate 2>/dev/null)" +%s 2>/dev/null || echo 0)
end(){ date -d "$(openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null || echo 0; }
if grep -q 'CERTIFICATE' /root/mock2/q10-before.txt 2>/dev/null && grep -q 'apiserver' /root/mock2/q10-before.txt; then pass "q10-before.txt has the kubeadm expiration overview"; else fail "q10-before.txt missing or not 'kubeadm certs check-expiration' output"; fi
for c in apiserver apiserver-kubelet-client front-proxy-client etcd/server; do
  N=$(end < /etc/kubernetes/pki/$c.crt)
  if [ "$N" -gt "$OLD" ]; then pass "$c.crt renewed"; else fail "$c.crt not renewed"; fi
done
S=$(echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | end)
if [ "$S" -gt "$OLD" ]; then pass "API server on :6443 serves the renewed certificate"; else fail "API server still serves the old certificate - restart it"; fi
check "kubectl works" kubectl get nodes
summary
