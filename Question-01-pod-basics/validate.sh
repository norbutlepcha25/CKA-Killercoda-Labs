#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-01
banner "Validating Question 01"
check "namespace $NS exists" kubectl get ns $NS
eq "pod web is Running" "$(jp '{.status.phase}' pod web -n $NS)" Running
eq "image is nginx:1.27" "$(jp '{.spec.containers[0].image}' pod web -n $NS)" nginx:1.27
eq "label app=web" "$(jp '{.metadata.labels.app}' pod web -n $NS)" web
eq "label version=v1" "$(jp '{.metadata.labels.version}' pod web -n $NS)" v1
eq "label tier removed" "$(jp '{.metadata.labels.tier}' pod web -n $NS)" ""
eq "requests.memory 64Mi" "$(jp '{.spec.containers[0].resources.requests.memory}' pod web -n $NS)" 64Mi
eq "requests.cpu 100m" "$(jp '{.spec.containers[0].resources.requests.cpu}' pod web -n $NS)" 100m
eq "limits.memory 128Mi" "$(jp '{.spec.containers[0].resources.limits.memory}' pod web -n $NS)" 128Mi
eq "limits.cpu 250m" "$(jp '{.spec.containers[0].resources.limits.cpu}' pod web -n $NS)" 250m
summary
