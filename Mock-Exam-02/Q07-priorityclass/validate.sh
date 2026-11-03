#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 07"
eq "critical-workload value" "$(jp '{.value}' pc critical-workload)" 1000
eq "standard-workload value" "$(jp '{.value}' pc standard-workload)" 100
for p in critical-workload standard-workload; do
  eq "$p preemptionPolicy" "$(jp '{.preemptionPolicy}' pc $p)" PreemptLowerPriority
  if [ "$(jp '{.globalDefault}' pc $p)" = true ]; then fail "$p must not be globalDefault"; else pass "$p is not globalDefault"; fi
done
for p in critical-pod-1:1000 critical-pod-2:1000 standard-pod:100; do
  n=${p%%:*}; v=${p##*:}
  eq "$n Running" "$(jp '{.status.phase}' pod $n -n priority-demo)" Running
  eq "$n priority" "$(jp '{.spec.priority}' pod $n -n priority-demo)" $v
done
eq "first evicted (q07-first-evicted.txt)" "$(filecontent /root/mock2/q07-first-evicted.txt)" standard-pod
summary
