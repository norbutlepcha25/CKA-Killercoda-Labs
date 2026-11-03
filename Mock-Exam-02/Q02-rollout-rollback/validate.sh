#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 02"
NS=payments; D="deploy payment-service -n $NS"
eq "broken revision in q02-bad-revision.txt" "$(filecontent /root/mock2/q02-bad-revision.txt)" 4
eq "image is nginx:1.27" "$(jp '{.spec.template.spec.containers[0].image}' $D)" nginx:1.27
check "rollout complete" kubectl rollout status $D --timeout=90s
eq "3 replicas available" "$(jp '{.status.availableReplicas}' $D)" 3
eq "no old/broken pods left (updatedReplicas = replicas)" "$(jp '{.status.updatedReplicas}/{.status.replicas}' $D)" 3/3
summary
