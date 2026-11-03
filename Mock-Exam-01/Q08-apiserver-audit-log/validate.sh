#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 08"
M=/etc/kubernetes/manifests/kube-apiserver.yaml; LOG=/var/log/kubernetes/audit/audit.log
grep -q -- '--audit-policy-file=/etc/kubernetes/audit/policy.yaml' $M && pass "--audit-policy-file set" || fail "--audit-policy-file=/etc/kubernetes/audit/policy.yaml missing in $M"
grep -q -- "--audit-log-path=$LOG" $M && pass "--audit-log-path set" || fail "--audit-log-path=$LOG missing"
grep -q -- '--audit-log-maxbackup=2' $M && pass "--audit-log-maxbackup=2" || fail "--audit-log-maxbackup=2 missing"
grep -q -- '--audit-log-maxsize=10' $M && pass "--audit-log-maxsize=10" || fail "--audit-log-maxsize=10 missing"
grep -q 'configmaps' /etc/kubernetes/audit/policy.yaml 2>/dev/null && pass "policy mentions configmaps" || fail "policy file missing or does not mention configmaps"
if kubectl get --raw=/readyz >/dev/null 2>&1; then pass "API server healthy"; else fail "API server not answering"; fi
if grep -q '"resource":"configmaps"' $LOG 2>/dev/null; then pass "audit log contains ConfigMap events"; else fail "no ConfigMap events in $LOG"; fi
eq "username in q08-user.txt" "$(filecontent /root/mock1/q08-user.txt)" system:serviceaccount:ops:config-sync
eq "response code in q08-code.txt" "$(filecontent /root/mock1/q08-code.txt)" 403
TS=$(filecontent /root/mock1/q08-time.txt | tr -d '"')
if [ -n "$TS" ] && grep -F "\"requestReceivedTimestamp\":\"$TS\"" $LOG* 2>/dev/null | grep -q 'config-sync'; then pass "q08-time.txt matches a config-sync request"; else fail "q08-time.txt ('$TS') is not the timestamp of a config-sync request"; fi
summary
