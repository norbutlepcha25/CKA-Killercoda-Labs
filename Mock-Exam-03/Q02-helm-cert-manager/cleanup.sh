#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete clusterissuer course-issuer --ignore-not-found >/dev/null 2>&1
command -v helm >/dev/null && helm uninstall cert-manager -n cert-manager >/dev/null 2>&1
kubectl get crd -o name 2>/dev/null | grep 'cert-manager.io' | xargs -r kubectl delete >/dev/null 2>&1
del_ns cert-manager
rm -rf /root/mock3/2
true
