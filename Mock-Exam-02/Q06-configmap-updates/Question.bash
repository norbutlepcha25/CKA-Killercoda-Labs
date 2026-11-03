# Mock Exam 02 - Question 06 - ConfigMap Updates  (Workloads | 8 min)
#
# Namespace config-demo has ConfigMap app-config (key mode=blue) and two Deployments that use it:
#   volume-app - mounts the ConfigMap as a volume at /config
#   env-app    - reads the key into the environment variable MODE
#
# Tasks
# 1. Change mode in ConfigMap app-config to green
# 2. volume-app must pick up the change WITHOUT restarting its pod: verify /config/mode in the
#    running pod shows green (this can take up to about a minute)
# 3. env-app still sees blue. Make it pick up the new value with a rolling restart
#    (do not delete or recreate the Deployment)
