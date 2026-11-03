#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 13"
L(){ jp "{.metadata.labels.pod-security\.kubernetes\.io/$2}" ns "$1"; }
eq "legacy-root enforce=baseline" "$(L legacy-root enforce)" baseline
eq "restricted still enforce=restricted" "$(L restricted enforce)" restricted
eq "root-app Running in legacy-root" "$(jp '{.status.phase}' pod root-app -n legacy-root)" Running
eq "root-app image" "$(jp '{.spec.containers[0].image}' pod root-app -n legacy-root)" nginx:1.27
eq "root-app runs as uid 0" "$(kubectl exec root-app -n legacy-root -- id -u 2>/dev/null)" 0
if kubectl run pss-check -n restricted --image=nginx:1.27 --dry-run=server >/dev/null 2>&1; then fail "restricted admits a root pod"; else pass "restricted still rejects a root pod"; fi
if kubectl run pss-check -n legacy-root --image=nginx:1.27 --privileged --dry-run=server >/dev/null 2>&1; then fail "legacy-root admits a privileged pod"; else pass "legacy-root rejects a privileged pod"; fi
summary
