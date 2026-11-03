#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-17; P="pod broken-app -n $NS"
banner "Validating Question 17"
eq "pod broken-app Running" "$(jp '{.status.phase}' $P)" Running
eq "pod image nginx:1.27" "$(jp '{.spec.containers[0].image}' $P)" nginx:1.27
nonempty "an ephemeral debug container was attached" "$(jp '{.spec.ephemeralContainers[*].name}' $P)"
if jp '{.spec.ephemeralContainers[*].image}' $P | grep -q 'busybox:1.36'; then pass "debug container uses busybox:1.36"; else fail "no ephemeral container with busybox:1.36"; fi
if jp '{.spec.ephemeralContainers[*].targetContainerName}' $P | grep -qw broken-app; then pass "debug container targets broken-app (shared process namespace)"; else fail "ephemeral container is not targeting broken-app (use --target=broken-app)"; fi
ND=$(kubectl get pods -A --no-headers 2>/dev/null | awk '$2 ~ /^node-debugger-/ {print $2}' | head -1)
if [ -n "$ND" ]; then pass "node debug pod found ($ND)"; else fail "no node-debugger-* pod found (Part B: kubectl debug node/<node>)"; fi
summary
