#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 14"
REAL=$(openssl x509 -noout -enddate -in /etc/kubernetes/pki/apiserver.crt | cut -d= -f2)
same_time "expiration date matches apiserver.crt" "$(filecontent /root/mock3/14/expiration | head -1)" "$REAL"
if grep -Eq '^[[:space:]]*kubeadm +certs +renew +apiserver[[:space:]]*$' /root/mock3/14/kubeadm-renew-certs.sh 2>/dev/null; then pass "renew command"; else fail "kubeadm-renew-certs.sh must contain: kubeadm certs renew apiserver"; fi
summary
