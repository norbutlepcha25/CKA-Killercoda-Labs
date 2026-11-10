#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 01"
D=/root/mock3/1
eq "contexts file lists all contexts" "$(filecontent $D/contexts | sort | tr '\n' ' ')" "cluster-admin cluster-w100 cluster-w200 "
eq "current-context file" "$(filecontent $D/current-context)" cluster-w200
GOT=$(openssl x509 -noout -fingerprint -sha256 -in $D/cert 2>/dev/null)
EXP=$(openssl x509 -noout -fingerprint -sha256 -in /root/.cka-lab/mock3-q1-expected.crt 2>/dev/null)
if [ -n "$GOT" ] && [ "$GOT" = "$EXP" ]; then pass "cert is the decoded certificate of account-0027@internal"
else fail "cert is missing, not decoded or belongs to another user"; fi
summary
