#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns monitoring
if [ -f /root/.cka-lab/mock2-q04-added-taint ]; then
  kubectl taint node "$(cp_node)" node-role.kubernetes.io/control-plane:NoSchedule- >/dev/null 2>&1
  rm -f /root/.cka-lab/mock2-q04-added-taint
fi
true
