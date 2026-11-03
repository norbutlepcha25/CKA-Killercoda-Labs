#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 09"
C="cronjob backup-job -n backup"
check "CronJob backup-job exists" kubectl get $C
oneof "schedule" "$(jp '{.spec.schedule}' $C)" "0 2 * * *" "00 02 * * *" "0 02 * * *" "00 2 * * *"
eq "successfulJobsHistoryLimit" "$(jp '{.spec.successfulJobsHistoryLimit}' $C)" 3
eq "suspended" "$(jp '{.spec.suspend}' $C)" true
eq "image" "$(jp '{.spec.jobTemplate.spec.template.spec.containers[0].image}' $C)" busybox:1.37
eq "restartPolicy" "$(jp '{.spec.jobTemplate.spec.template.spec.restartPolicy}' $C)" OnFailure
eq "Job backup-manual created from the CronJob" "$(jp '{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}' job backup-manual -n backup)" CronJob/backup-job
if kubectl wait --for=condition=Complete job/backup-manual -n backup --timeout=60s >/dev/null 2>&1; then pass "backup-manual completed"; else fail "backup-manual did not complete"; fi
if kubectl logs job/backup-manual -n backup 2>/dev/null | grep -q 'Running backup'; then pass "backup-manual printed 'Running backup'"; else fail "backup-manual logs do not contain 'Running backup'"; fi
summary
