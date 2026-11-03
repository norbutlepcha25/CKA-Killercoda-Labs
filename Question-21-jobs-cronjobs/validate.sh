#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 21"
J="job cleanup-job"
eq "cleanup-job completions 3" "$(jp '{.spec.completions}' $J)" 3
eq "cleanup-job parallelism 1" "$(jp '{.spec.parallelism}' $J)" 1
eq "cleanup-job image busybox:1.37" "$(jp '{.spec.template.spec.containers[0].image}' $J)" busybox:1.37
eq "cleanup-job succeeded 3 times" "$(jp '{.status.succeeded}' $J)" 3
if kubectl logs -l job-name=cleanup-job --tail=-1 2>/dev/null | grep -q "Cleanup complete"; then pass "cleanup-job logs contain 'Cleanup complete'"; else fail "cleanup-job logs missing 'Cleanup complete'"; fi
C="cronjob hourly-backup"
eq "CronJob schedule '0 * * * *'" "$(jp '{.spec.schedule}' $C)" "0 * * * *"
eq "successfulJobsHistoryLimit 3" "$(jp '{.spec.successfulJobsHistoryLimit}' $C)" 3
eq "CronJob image busybox:1.37" "$(jp '{.spec.jobTemplate.spec.template.spec.containers[0].image}' $C)" busybox:1.37
eq "manual-backup created from the CronJob" "$(jp '{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}' job manual-backup)" CronJob/hourly-backup
eq "manual-backup succeeded" "$(jp '{.status.succeeded}' job manual-backup)" 1
if kubectl logs job/manual-backup 2>/dev/null | grep -q "backup-script.sh"; then pass "manual-backup logged output"; else fail "manual-backup logs missing 'backup-script.sh'"; fi
summary
