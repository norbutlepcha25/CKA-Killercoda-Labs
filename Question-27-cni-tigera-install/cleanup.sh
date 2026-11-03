#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
kubectl delete pod cni-test-a cni-test-b --ignore-not-found --now >/dev/null 2>&1
echo "Note: the removed CNI is not reinstalled - start a fresh Killercoda session for other labs."
true
