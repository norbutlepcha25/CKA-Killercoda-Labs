#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 05"
F=/root/mock2
L=$(grep -c . $F/q05-apiserver.log 2>/dev/null); L=${L:-0}
if [ "$L" -ge 20 ] && grep -qE '^[IWE][0-9]{4} ' $F/q05-apiserver.log; then pass "q05-apiserver.log has kube-apiserver log lines ($L)"; else fail "q05-apiserver.log missing or not kube-apiserver logs ($L lines)"; fi
if grep -q ':6443' $F/q05-listen.txt 2>/dev/null && grep -q 'kube-apiserver' $F/q05-listen.txt; then pass "q05-listen.txt shows kube-apiserver on 6443"; else fail "q05-listen.txt does not show kube-apiserver listening on :6443"; fi
if grep -q 'readyz check passed' $F/q05-readyz.txt 2>/dev/null && grep -q '\[+\]etcd ok' $F/q05-readyz.txt; then pass "q05-readyz.txt has the verbose readyz output"; else fail "q05-readyz.txt is not the /readyz?verbose output"; fi
eq "top user in q05-top-user.txt" "$(filecontent $F/q05-top-user.txt)" system:serviceaccount:reports:report-bot
eq "response code in q05-code.txt" "$(filecontent $F/q05-code.txt)" 403
eq "Deployment reports/report-bot scaled to 0" "$(jp '{.spec.replicas}' deploy report-bot -n reports)" 0
summary
