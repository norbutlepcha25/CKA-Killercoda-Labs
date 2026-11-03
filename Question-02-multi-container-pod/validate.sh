#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-02; P="pod logger -n $NS"
banner "Validating Question 02"
eq "pod logger is Running" "$(jp '{.status.phase}' $P)" Running
eq "init container log-agent exists" "$(jp '{.spec.initContainers[?(@.name=="log-agent")].name}' $P)" log-agent
eq "log-agent restartPolicy Always (native sidecar)" "$(jp '{.spec.initContainers[?(@.name=="log-agent")].restartPolicy}' $P)" Always
eq "log-agent image busybox:1.36" "$(jp '{.spec.initContainers[?(@.name=="log-agent")].image}' $P)" busybox:1.36
eq "app image busybox:1.36" "$(jp '{.spec.containers[?(@.name=="app")].image}' $P)" busybox:1.36
nonempty "volume log-volume is an emptyDir" "$(jp '{.spec.volumes[?(@.name=="log-volume")].emptyDir}' $P)"
eq "log-agent mounts log-volume at /var/log/app" "$(jp '{.spec.initContainers[?(@.name=="log-agent")].volumeMounts[?(@.name=="log-volume")].mountPath}' $P)" /var/log/app
eq "app mounts log-volume at /var/log/app" "$(jp '{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="log-volume")].mountPath}' $P)" /var/log/app
eq "log-agent is running" "$(jp '{.status.initContainerStatuses[?(@.name=="log-agent")].started}' $P)" true
eq "app is ready" "$(jp '{.status.containerStatuses[?(@.name=="app")].ready}' $P)" true
if kubectl logs logger -n $NS -c log-agent --tail=5 2>/dev/null | grep -q .; then pass "sidecar logs show the app output"; else fail "sidecar logs are empty"; fi
summary
