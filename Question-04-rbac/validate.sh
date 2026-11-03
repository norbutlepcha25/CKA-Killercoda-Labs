#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-04; AS=system:serviceaccount:exercise-04:dev-sa
can(){ kubectl auth can-i "$@" --as=$AS 2>/dev/null | awk '{print $1}'; }
banner "Validating Question 04"
check "ServiceAccount dev-sa exists" kubectl get sa dev-sa -n $NS
check "Role pod-manager exists" kubectl get role pod-manager -n $NS
eq "RoleBinding dev-pod-access -> Role pod-manager" "$(jp '{.roleRef.kind}/{.roleRef.name}' rolebinding dev-pod-access -n $NS)" Role/pod-manager
eq "RoleBinding subject is dev-sa" "$(jp '{.subjects[0].kind}/{.subjects[0].namespace}/{.subjects[0].name}' rolebinding dev-pod-access -n $NS)" ServiceAccount/exercise-04/dev-sa
for v in get list watch create delete; do eq "can $v pods in $NS" "$(can $v pods -n $NS)" yes; done
for v in get list; do eq "can $v services in $NS" "$(can $v services -n $NS)" yes; done
eq "cannot delete services in $NS" "$(can delete services -n $NS)" no
eq "cannot update pods in $NS" "$(can update pods -n $NS)" no
eq "cannot list pods in default" "$(can list pods -n default)" no
eq "cannot delete deployments in $NS" "$(can delete deployments.apps -n $NS)" no
eq "ClusterRoleBinding dev-node-access -> ClusterRole node-viewer" "$(jp '{.roleRef.name}' clusterrolebinding dev-node-access)" node-viewer
eq "can list nodes" "$(can list nodes)" yes
eq "can get nodes" "$(can get nodes)" yes
eq "cannot delete nodes" "$(can delete nodes)" no
summary
