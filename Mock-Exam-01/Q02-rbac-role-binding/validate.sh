#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 02"
check "Role staging-reader exists" kubectl get role staging-reader -n staging
check "RoleBinding staging-reader-dev-user exists" kubectl get rolebinding staging-reader-dev-user -n staging
eq "RoleBinding refers to Role staging-reader" "$(jp '{.roleRef.kind}/{.roleRef.name}' rolebinding staging-reader-dev-user -n staging)" Role/staging-reader
eq "RoleBinding subject is User dev-user" "$(jp '{.subjects[0].kind}/{.subjects[0].name}' rolebinding staging-reader-dev-user -n staging)" User/dev-user
eq "dev-user can list pods in staging" "$(kubectl auth can-i list pods --as=dev-user -n staging 2>/dev/null)" yes
eq "dev-user can list deployments in staging" "$(kubectl auth can-i list deployments.apps --as=dev-user -n staging 2>/dev/null)" yes
eq "dev-user can NOT list pods in default" "$(kubectl auth can-i list pods --as=dev-user -n default 2>/dev/null)" no
eq "dev-user can NOT delete pods in staging (least privilege)" "$(kubectl auth can-i delete pods --as=dev-user -n staging 2>/dev/null)" no
summary
