#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 12"
NS=project-jaguar; DP="deploy deploy-important -n $NS"
eq "replicas" "$(jp '{.spec.replicas}' $DP)" 3
eq "Deployment label id" "$(jp '{.metadata.labels.id}' $DP)" very-important
eq "Pod label id" "$(jp '{.spec.template.metadata.labels.id}' $DP)" very-important
eq "containers" "$(jp '{range .spec.template.spec.containers[*]}{.name}={.image} {end}' $DP)" "container1=nginx:1-alpine container2=registry.k8s.io/pause:3.10 "
AA=$(jp '{.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[*].topologyKey}' $DP)
TS=$(jp '{.spec.template.spec.topologySpreadConstraints[?(@.whenUnsatisfiable=="DoNotSchedule")].topologyKey}' $DP)
if echo "$AA $TS" | grep -qw kubernetes.io/hostname; then pass "required podAntiAffinity or DoNotSchedule spread on kubernetes.io/hostname"; else fail "no required anti-affinity / DoNotSchedule topologySpreadConstraint with topologyKey kubernetes.io/hostname"; fi
# nodes the Pods can land on = nodes without a NoSchedule/NoExecute taint
S=0; for n in $(kubectl get nodes -o name); do
  t=$(kubectl get $n -o jsonpath='{.spec.taints[*].effect}'); echo "$t" | grep -Eq 'NoSchedule|NoExecute' || S=$((S+1)); done
EXP=$(( S < 3 ? S : 3 ))
sleep 5
R=$(jp '{.status.readyReplicas}' $DP); eq "ready replicas (= schedulable nodes, max 3)" "${R:-0}" "$EXP"
DUP=$(kubectl get pod -n $NS -l id=very-important -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sed '/^$/d' | sort | uniq -d)
if [ -z "$DUP" ]; then pass "never two Pods on one node"; else fail "two Pods on node $DUP"; fi
summary
