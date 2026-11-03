#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-03
banner "Validating Question 03"
eq "ConfigMap APP_MODE=production" "$(jp '{.data.APP_MODE}' cm app-config -n $NS)" production
eq "ConfigMap LOG_LEVEL=debug" "$(jp '{.data.LOG_LEVEL}' cm app-config -n $NS)" debug
eq "Secret DB_USER=admin" "$(jp '{.data.DB_USER}' secret db-creds -n $NS | base64 -d 2>/dev/null)" admin
eq "Secret DB_PASS=s3cretP@ss" "$(jp '{.data.DB_PASS}' secret db-creds -n $NS | base64 -d 2>/dev/null)" 's3cretP@ss'
eq "pod app is Running" "$(jp '{.status.phase}' pod app -n $NS)" Running
eq "pod image busybox:1.36" "$(jp '{.spec.containers[0].image}' pod app -n $NS)" busybox:1.36
ENV=$(kubectl exec app -n $NS -- env 2>/dev/null)
for kv in APP_MODE=production LOG_LEVEL=debug DB_USER=admin 'DB_PASS=s3cretP@ss'; do
  if echo "$ENV" | grep -qx "$kv"; then pass "env $kv"; else fail "env $kv missing in pod"; fi
done
eq "/etc/config/APP_MODE file mounted" "$(kubectl exec app -n $NS -- cat /etc/config/APP_MODE 2>/dev/null)" production
eq "/etc/config/LOG_LEVEL file mounted" "$(kubectl exec app -n $NS -- cat /etc/config/LOG_LEVEL 2>/dev/null)" debug
summary
