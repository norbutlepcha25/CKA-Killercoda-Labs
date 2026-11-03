#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do on_node "$n" "mkdir -p /tmp/k8s-pv"; done
echo "Lab ready. /tmp/k8s-pv was created on every node. Use node $(worker_node) for the PV nodeAffinity."
