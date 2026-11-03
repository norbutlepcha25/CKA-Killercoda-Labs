#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 12"
D="database.example.com prod-db -n crd-demo"
eq "CRD name in q12-crd.txt" "$(filecontent /root/mock2/q12-crd.txt)" databases.example.com
check "Database prod-db exists" kubectl get $D
eq "prod-db spec" "$(jp '{.spec.engine}/{.spec.version}/{.spec.storage}' $D)" postgres/15/100Gi
if kubectl get database.example.com old-db -n crd-demo >/dev/null 2>&1; then fail "old-db still exists"; else pass "old-db deleted"; fi
if grep -q '/registry/example.com/databases/crd-demo/prod-db' /root/mock2/q12-etcd.txt 2>/dev/null; then pass "q12-etcd.txt shows the etcd key of prod-db"; else fail "q12-etcd.txt does not contain /registry/example.com/databases/crd-demo/prod-db"; fi
summary
