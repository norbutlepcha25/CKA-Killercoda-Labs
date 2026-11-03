#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete ingress api-ingress api-health -n default --ignore-not-found >/dev/null 2>&1
kubectl delete deploy api -n default --ignore-not-found >/dev/null 2>&1
kubectl delete svc api -n default --ignore-not-found >/dev/null 2>&1
kubectl delete secret api-tls-cert -n default --ignore-not-found >/dev/null 2>&1
true
