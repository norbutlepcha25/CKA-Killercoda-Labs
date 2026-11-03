#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 06"
NS=config-demo
eq "ConfigMap mode=green" "$(jp '{.data.mode}' cm app-config -n $NS)" green
P=$(kubectl get pod -n $NS -l app=volume-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
eq "volume-app pod is still the original pod" "$(jp '{.metadata.uid}' pod $P -n $NS)" "$(cat /root/.cka-lab/mock2-q06-uid 2>/dev/null)"
eq "volume-app pod has no restarts" "$(jp '{.status.containerStatuses[0].restartCount}' pod $P -n $NS)" 0
V=""; for i in $(seq 1 18); do V=$(kubectl exec $P -n $NS -- cat /config/mode 2>/dev/null); [ "$V" = green ] && break; sleep 5; done
eq "volume-app sees /config/mode=green" "$V" green
check "env-app rollout complete" kubectl rollout status deploy/env-app -n $NS --timeout=60s
eq "env-app sees MODE=green" "$(kubectl exec deploy/env-app -n $NS -- printenv MODE 2>/dev/null)" green
summary
