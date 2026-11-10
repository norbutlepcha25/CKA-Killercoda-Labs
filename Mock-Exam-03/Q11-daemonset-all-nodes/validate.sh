#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 11"
NS=project-tiger; DS="ds ds-important -n $NS"
check "DaemonSet ds-important exists" kubectl get $DS
eq "label id" "$(jp '{.metadata.labels.id}' $DS)" ds-important
eq "label uuid" "$(jp '{.metadata.labels.uuid}' $DS)" 18426a0b-5f59-4e10-923f-c0e078e82462
eq "pod template labels" "$(jp '{.spec.template.metadata.labels.id} {.spec.template.metadata.labels.uuid}' $DS)" "ds-important 18426a0b-5f59-4e10-923f-c0e078e82462"
eq "image" "$(jp '{.spec.template.spec.containers[0].image}' $DS)" httpd:2-alpine
eq "requests" "$(jp '{.spec.template.spec.containers[0].resources.requests.cpu} {.spec.template.spec.containers[0].resources.requests.memory}' $DS)" "10m 10Mi"
N=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
eq "Pods scheduled on all $N nodes" "$(jp '{.status.desiredNumberScheduled}' $DS)" "$N"
kubectl -n $NS rollout status ds/ds-important --timeout=90s >/dev/null 2>&1
eq "Pods ready on all $N nodes" "$(jp '{.status.numberReady}' $DS)" "$N"
summary
