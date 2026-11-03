#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
echo "Lab ready. Worker node is: $(worker_node). Work in the default namespace."
if kubectl get node "$(cp_node)" -o jsonpath='{.spec.taints[*].effect}' | grep -q NoSchedule; then
  echo "Note: the control plane is tainted NoSchedule, so drained pods will wait in Pending until you uncordon."
fi
