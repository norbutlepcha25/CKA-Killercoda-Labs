#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 22"
eq "high-priority value 1000" "$(jp '{.value}' priorityclass high-priority)" 1000
eq "high-priority preemptionPolicy PreemptLowerPriority" "$(jp '{.preemptionPolicy}' priorityclass high-priority)" PreemptLowerPriority
eq "low-priority value 10" "$(jp '{.value}' priorityclass low-priority)" 10
eq "low-priority preemptionPolicy Never" "$(jp '{.preemptionPolicy}' priorityclass low-priority)" Never
eq "critical-app Running" "$(jp '{.status.phase}' pod critical-app)" Running
eq "critical-app image nginx:1.28" "$(jp '{.spec.containers[0].image}' pod critical-app)" nginx:1.28
eq "critical-app class/priority" "$(jp '{.spec.priorityClassName}/{.spec.priority}' pod critical-app)" high-priority/1000
eq "background-job Running" "$(jp '{.status.phase}' pod background-job)" Running
eq "background-job image busybox:1.37" "$(jp '{.spec.containers[0].image}' pod background-job)" busybox:1.37
eq "background-job class/priority" "$(jp '{.spec.priorityClassName}/{.spec.priority}' pod background-job)" low-priority/10
summary
