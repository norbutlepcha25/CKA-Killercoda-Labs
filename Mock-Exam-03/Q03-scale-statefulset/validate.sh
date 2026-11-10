#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 03"
check "StatefulSet o3db still exists" kubectl get sts o3db -n project-h800
eq "StatefulSet o3db replicas" "$(jp '{.spec.replicas}' sts o3db -n project-h800)" 1
kubectl -n project-h800 wait --for=delete pod/o3db-1 --timeout=60s >/dev/null 2>&1
eq "o3db Pods running" "$(kubectl get pod -n project-h800 -l app=o3db --no-headers 2>/dev/null | wc -l | tr -d ' ')" 1
eq "Deployment h800-api untouched" "$(jp '{.spec.replicas}' deploy h800-api -n project-h800)" 2
summary
