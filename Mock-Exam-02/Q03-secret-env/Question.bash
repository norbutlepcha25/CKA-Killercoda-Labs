# Mock Exam 02 - Question 03 - Secrets and Environment Variables  (Workloads | 7 min)
#
# Deployment app-deploy in namespace secrets-demo (container app) needs database credentials.
#
# Tasks
# 1. Create a Secret db-creds in secrets-demo with keys:
#      username=dbuser   password=secret123   database=appdb
# 2. Expose them to the app container as the environment variables DB_USERNAME, DB_PASSWORD and
#    DB_DATABASE, taken from the Secret (not as files, and not as plain values in the Deployment)
# 3. Verify the new pod sees the variables, without the values appearing in the pod logs
