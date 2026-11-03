#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 14"
L(){ jp "{.metadata.labels.pod-security\.kubernetes\.io/$1}" ns restricted; }
eq "enforce=restricted" "$(L enforce)" restricted
eq "audit=baseline" "$(L audit)" baseline
if kubectl run pss-check -n restricted --image=nginx:1.27 --privileged --dry-run=server >/dev/null 2>&1; then fail "a privileged pod would be admitted"; else pass "privileged pod denied"; fi
if grep -q 'violates PodSecurity' /root/mock1/q14-denied.txt 2>/dev/null; then pass "denial saved in q14-denied.txt"; else fail "/root/mock1/q14-denied.txt missing or not a PodSecurity denial"; fi
summary
