# Question 03 - ConfigMap & Secret  (Workloads & Scheduling | Easy | 10 min)
#
# Tasks
# 1. Create a namespace called exercise-03
# 2. Create a ConfigMap named app-config with:
#    - Key APP_MODE = production
#    - Key LOG_LEVEL = debug
# 3. Create a Secret named db-creds with:
#    - Key DB_USER = admin
#    - Key DB_PASS = s3cretP@ss
# 4. Create a pod named app that:
#    - Uses image busybox:1.36, command sleep 3600
#    - Loads APP_MODE and LOG_LEVEL from the ConfigMap as env vars
#    - Loads DB_USER and DB_PASS from the Secret as env vars
#    - Mounts the entire ConfigMap as files at /etc/config/
# 5. Verify the env vars are set inside the pod
# 6. Verify the mounted files exist at /etc/config/
