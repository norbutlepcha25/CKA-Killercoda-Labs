#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 04"
DS="ds monitoring-agent -n monitoring"
T=$(jp '{range .spec.template.spec.tolerations[*]}{.key}|{.operator}|{.effect}{"\n"}{end}' $DS)
if echo "$T" | grep -qE '^node-role.kubernetes.io/control-plane\|(Exists|Equal|)\|(NoSchedule|)$' || echo "$T" | grep -qE '^\|Exists\|'; then pass "tolerates node-role.kubernetes.io/control-plane:NoSchedule"; else fail "no toleration for node-role.kubernetes.io/control-plane:NoSchedule"; fi
eq "image busybox:1.37" "$(jp '{.spec.template.spec.containers[0].image}' $DS)" busybox:1.37
kubectl rollout status $DS --timeout=120s >/dev/null 2>&1
N=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
eq "desired pods = number of nodes" "$(jp '{.status.desiredNumberScheduled}' $DS)" "$N"
eq "ready pods = number of nodes" "$(jp '{.status.numberReady}' $DS)" "$N"
CP=$(cp_node)
if kubectl get pods -n monitoring -l app=monitoring-agent -o jsonpath='{.items[*].spec.nodeName}' | grep -qw "$CP"; then pass "agent runs on $CP"; else fail "no agent on $CP"; fi
summary
