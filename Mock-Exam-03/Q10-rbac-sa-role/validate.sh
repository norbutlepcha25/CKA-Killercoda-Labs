#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 10"
NS=project-hamster; A="--as system:serviceaccount:$NS:processor"
check "ServiceAccount processor exists" kubectl get sa processor -n $NS
check "Role processor exists" kubectl get role processor -n $NS
eq "RoleBinding processor -> Role processor" "$(jp '{.roleRef.kind}/{.roleRef.name}' rolebinding processor -n $NS)" Role/processor
if jp '{.subjects[*].name}' rolebinding processor -n $NS | grep -qw processor; then pass "RoleBinding subject is SA processor"; else fail "RoleBinding does not bind SA processor"; fi
can(){ kubectl -n $NS auth can-i "$1" "$2" $A 2>/dev/null; }
eq "can create secrets" "$(can create secrets)" yes
eq "can create configmaps" "$(can create configmaps)" yes
eq "cannot create pods" "$(can create pods)" no
eq "cannot delete secrets" "$(can delete secrets)" no
eq "cannot get configmaps" "$(can get configmaps)" no
eq "cannot list secrets" "$(can list secrets)" no
eq "cannot create secrets in default" "$(kubectl -n default auth can-i create secrets $A 2>/dev/null)" no
summary
