#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-24
banner "Validating Question 24"
eq "PriorityClass high-priority value 999999" "$(jp '{.value}' priorityclass high-priority)" 999999
eq "description 'Critical workload'" "$(jp '{.description}' priorityclass high-priority)" "Critical workload"
eq "critical-app image busybox:1.36" "$(jp '{.spec.template.spec.containers[0].image}' deploy critical-app -n $NS)" busybox:1.36
eq "critical-app replicas 1" "$(jp '{.spec.replicas}' deploy critical-app -n $NS)" 1
eq "critical-app patched with priorityClassName" "$(jp '{.spec.template.spec.priorityClassName}' deploy critical-app -n $NS)" high-priority
eq "critical-app ready" "$(jp '{.status.readyReplicas}' deploy critical-app -n $NS)" 1
# ignore pods of the old ReplicaSet that are still terminating after the patch
PRI=$(jp '{range .items[*]}{.metadata.deletionTimestamp}|{.spec.priority}{"\n"}{end}' pod -n $NS -l app=critical-app | grep '^|' | cut -d'|' -f2 | sort -u | tr '\n' ' ' | sed 's/ $//')
eq "critical-app pod priority 999999" "$PRI" 999999
eq "normal-app ready" "$(jp '{.status.readyReplicas}' deploy normal-app -n $NS)" 1
NP=$(jp '{.items[0].spec.priority}' pod -n $NS -l app=normal-app --field-selector=status.phase=Running)
if [ -n "$NP" ] && [ "$NP" -lt 999999 ]; then pass "normal-app pod priority ($NP) is lower than critical-app"; else fail "normal-app pod priority should be lower than 999999 (got '$NP')"; fi
summary
