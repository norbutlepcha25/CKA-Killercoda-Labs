kubectl create cronjob backup-job -n backup --image=busybox:1.37 --schedule="0 2 * * *" \
  --dry-run=client -o yaml -- sh -c 'echo Running backup; date; sleep 5' > backup-job.yaml
# add successfulJobsHistoryLimit + suspend (kubectl create cronjob sets restartPolicy OnFailure already)
sed -i 's/^spec:$/spec:\n  successfulJobsHistoryLimit: 3\n  suspend: true/' backup-job.yaml
kubectl apply -f backup-job.yaml
kubectl get cronjob backup-job -n backup              # SUSPEND True, SCHEDULE 0 2 * * *
# suspend / resume an existing CronJob:
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":true}}'
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":false}}'
kubectl create job backup-manual -n backup --from=cronjob/backup-job
kubectl wait --for=condition=Complete job/backup-manual -n backup
kubectl logs job/backup-manual -n backup
# Cron fields: minute hour day-of-month month day-of-week. Times use the controller-manager's time
# zone unless you set spec.timeZone (e.g. "Etc/UTC").
