#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-tiger >/dev/null
echo "Q11 ready: namespace project-tiger"
echo "Control plane taints: $(jp '{.spec.taints[*].key}' node $(cp_node))"
