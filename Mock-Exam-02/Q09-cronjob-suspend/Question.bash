# Mock Exam 02 - Question 09 - CronJob Scheduling  (Workloads | 7 min)
#
# Tasks (namespace backup)
# 1. Create CronJob backup-job: image busybox:1.37, command  sh -c 'echo Running backup; date; sleep 5'
#    - runs every day at 02:00
#    - keeps only the last 3 successful Jobs
#    - restartPolicy OnFailure
# 2. Suspend the CronJob (it must not run for the next month)
# 3. While it is suspended, run it once by hand: create Job backup-manual from the CronJob and
#    make sure it completes
