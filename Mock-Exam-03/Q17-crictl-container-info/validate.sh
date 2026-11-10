#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 17"
NS=project-puma; P="pod tigers-reunite -n $NS"
eq "Pod image" "$(jp '{.spec.containers[0].image}' $P)" httpd:2-alpine
eq "Pod labels" "$(jp '{.metadata.labels.pod} {.metadata.labels.container}' $P)" "container pod"
eq "Pod Running" "$(jp '{.status.phase}' $P)" Running
N=$(jp '{.spec.nodeName}' $P)
FULL=$(jp '{.status.containerStatuses[0].containerID}' $P | sed 's#^.*://##')
RT=$(on_node "$N" "crictl inspect $FULL 2>/dev/null" | grep -m1 '"runtimeType"' | cut -d'"' -f4)
read -r ID GOTRT < <(filecontent /root/mock3/17/pod-container.txt | head -1)
if [ ${#ID} -ge 12 ] && [ "${FULL#$ID}" != "$FULL" ]; then pass "container ID ($ID)"; else fail "container ID wrong (got '$ID', container is ${FULL:0:13})"; fi
eq "runtimeType" "$GOTRT" "$RT"
L=$(on_node "$N" "crictl logs $FULL 2>&1" | head -1)
if [ -n "$L" ] && grep -qF "$L" /root/mock3/17/pod-container.log 2>/dev/null; then pass "pod-container.log holds the container logs"; else fail "pod-container.log missing or does not hold the container logs"; fi
summary
