#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns restricted >/dev/null
kubectl label ns restricted pod-security.kubernetes.io/enforce=restricted >/dev/null
echo "Q13 ready: namespace restricted enforces restricted."
