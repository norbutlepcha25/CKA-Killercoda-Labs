#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 03"
NS=secrets-demo; D="deploy app-deploy -n $NS"
d(){ jp "{.data.$1}" secret db-creds -n $NS | base64 -d 2>/dev/null; }
eq "secret username" "$(d username)" dbuser
eq "secret password" "$(d password)" secret123
eq "secret database" "$(d database)" appdb
for v in USERNAME PASSWORD DATABASE; do
  eq "DB_$v comes from secret db-creds" "$(jp "{.spec.template.spec.containers[0].env[?(@.name==\"DB_$v\")].valueFrom.secretKeyRef.name}" $D)" db-creds
done
if kubectl get $D -o json | grep -q 'secret123'; then fail "the password appears in plain text in the Deployment"; else pass "no plain-text password in the Deployment"; fi
if jp '{.spec.template.spec.volumes[*].secret.secretName}' $D | grep -q db-creds; then fail "secret is mounted as a volume (should be env only)"; else pass "secret not mounted as files"; fi
check "rollout complete" kubectl rollout status $D --timeout=90s
ENV=$(kubectl exec deploy/app-deploy -n $NS -c app -- env 2>/dev/null)
echo "$ENV" | grep -qx 'DB_USERNAME=dbuser' && echo "$ENV" | grep -qx 'DB_PASSWORD=secret123' && echo "$ENV" | grep -qx 'DB_DATABASE=appdb' \
  && pass "running pod sees DB_USERNAME / DB_PASSWORD / DB_DATABASE" || fail "running pod does not have the three DB_ variables"
if kubectl logs deploy/app-deploy -n $NS 2>/dev/null | grep -q secret123; then fail "password shows up in the pod logs"; else pass "password not in the pod logs"; fi
summary
