kubectl create job cleanup-job --image=busybox:1.37 --dry-run=client -o yaml -- echo "Cleanup complete" > job.yaml
# add under spec:  completions: 3   parallelism: 1
cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-job
spec:
  completions: 3
  parallelism: 1
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: cleanup
        image: busybox:1.37
        command: ["echo", "Cleanup complete"]
EOF
kubectl get job cleanup-job -w                    # COMPLETIONS 3/3
kubectl logs -l job-name=cleanup-job

cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hourly-backup
spec:
  schedule: "0 * * * *"
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: busybox:1.37
            command: ["sh", "-c", "echo \"Running backup-script.sh\"; date"]
EOF
kubectl get cronjob hourly-backup                 # LAST SCHEDULE / next run
kubectl create job manual-backup --from=cronjob/hourly-backup
kubectl logs job/manual-backup
