#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
# An upgrade cannot be rolled back. Cleanup only makes sure both nodes are schedulable again.
for n in $(kubectl get nodes -o name 2>/dev/null); do kubectl uncordon "${n#node/}" >/dev/null 2>&1; done
echo "Note: a kubeadm upgrade cannot be undone - start a fresh Killercoda session to practise it again."
