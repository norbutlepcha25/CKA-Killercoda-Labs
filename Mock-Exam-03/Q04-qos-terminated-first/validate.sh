#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 04"
EXP=$(kubectl -n project-c13 get pod -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort | tr '\n' ' ')
nonempty "BestEffort Pods exist in project-c13" "$EXP"
eq "pods-terminated-first.txt lists exactly the BestEffort Pods" "$(filecontent /root/mock3/4/pods-terminated-first.txt | sort | tr '\n' ' ')" "$EXP"
summary
