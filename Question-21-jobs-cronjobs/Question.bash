# Question 21 - Jobs and CronJobs  (Workloads & Scheduling | Medium | 15 min)
#
# Work in the default namespace.
#
# Tasks
# 1. Create a Job named cleanup-job that runs the image busybox:1.37 with command
#    echo "Cleanup complete". Run it 3 times (completions=3) serially (parallelism=1)
# 2. Verify the Job runs to completion (3/3) and check the pod logs
# 3. Create a CronJob named hourly-backup (image busybox:1.37) that runs every hour (0 * * * *)
#    with command: sh -c 'echo "Running backup-script.sh"; date'
#    Keep 3 successful job histories (successfulJobsHistoryLimit=3)
# 4. List CronJobs and check the next scheduled time
# 5. Manually trigger the CronJob once by creating a Job named manual-backup from it
# 6. Verify the manual Job ran and logged output
