#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
SP=$(grep staticPodPath /var/lib/kubelet/config.yaml 2>/dev/null | awk '{print $2}'); SP=${SP:-/etc/kubernetes/manifests}
POD="static-web-$(hostname)"
banner "Validating Question 10"
F=$(grep -l "name: static-web" "$SP"/*.yaml 2>/dev/null | head -1)
if [ -n "$F" ]; then
  echo "  (manifest found: $F - checking tasks 1-3)"
  eq "static pod $POD is Running" "$(jp '{.status.phase}' pod $POD)" Running
  eq "image nginx:1.27" "$(jp '{.spec.containers[0].image}' pod $POD)" nginx:1.27
  eq "containerPort 80" "$(jp '{.spec.containers[0].ports[0].containerPort}' pod $POD)" 80
  eq "pod is a mirror pod owned by the node" "$(jp '{.metadata.ownerReferences[0].kind}' pod $POD)" Node
  warn "now do tasks 4-6 (delete via kubectl, then remove the manifest) and validate again"
else
  echo "  (no static-web manifest in $SP - checking tasks 5-6)"
  sleep 5
  if kubectl get pod "$POD" >/dev/null 2>&1; then fail "pod $POD still exists"; else pass "manifest removed and pod $POD is gone"; fi
fi
summary
