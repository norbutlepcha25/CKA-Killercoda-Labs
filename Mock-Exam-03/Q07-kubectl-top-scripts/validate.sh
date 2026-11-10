#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 07"
N=/root/mock3/7/node.sh; P=/root/mock3/7/pod.sh
if grep -Eq '(^|[;&|[:space:]])kubectl +top +(node|nodes|no)([[:space:]]|$)' $N 2>/dev/null; then pass "node.sh uses kubectl top node"; else fail "node.sh does not run 'kubectl top node'"; fi
if grep -Eq '(^|[;&|[:space:]])kubectl +top +(pod|pods|po)([[:space:]]|$)' $P 2>/dev/null; then pass "pod.sh uses kubectl top pod"; else fail "pod.sh does not run 'kubectl top pod'"; fi
if grep -Eq -- '--containers(=true)?([[:space:]]|$)' $P 2>/dev/null; then pass "pod.sh shows containers"; else fail "pod.sh is missing --containers"; fi
if bash $N 2>/dev/null | grep -q 'CPU'; then pass "node.sh runs and prints usage"; else fail "node.sh does not print node usage"; fi
if bash $P >/dev/null 2>&1; then pass "pod.sh runs"; else fail "pod.sh fails when run"; fi
summary
