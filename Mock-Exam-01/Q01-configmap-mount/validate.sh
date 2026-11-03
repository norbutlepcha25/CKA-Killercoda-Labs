#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 01"
NS=production; WANT="database_host: postgres.production.svc.cluster.local"
check "ConfigMap app-config exists" kubectl get cm app-config -n $NS
eq "app-config key config.yaml" "$(jp '{.data.config\.yaml}' cm app-config -n $NS | sed 's/[[:space:]]*$//' | sed '/^$/d')" "$WANT"
if jp '{.spec.volumes[*].configMap.name}' pod app-frontend -n $NS | grep -qw app-config; then pass "pod mounts ConfigMap app-config"; else fail "pod app-frontend does not mount ConfigMap app-config"; fi
eq "pod app-frontend Running" "$(jp '{.status.phase}' pod app-frontend -n $NS)" Running
eq "container ready" "$(jp '{.status.containerStatuses[0].ready}' pod app-frontend -n $NS)" true
eq "/etc/app/config.yaml in the container" "$(kubectl exec app-frontend -n $NS -- cat /etc/app/config.yaml 2>/dev/null | sed 's/[[:space:]]*$//' | sed '/^$/d')" "$WANT"
summary
