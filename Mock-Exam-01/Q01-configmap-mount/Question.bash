# Mock Exam 01 - Question 01 - Pod Deployment Troubleshooting  (Troubleshooting | 8 min)
#
# Pod app-frontend in namespace production is in CrashLoopBackOff. Its container expects a
# config file at /etc/app/config.yaml, which the image does not contain.
# The pod manifest is at /root/mock1/app-frontend.yaml.
#
# Tasks
# 1. Create a ConfigMap named app-config in namespace production with a key config.yaml
#    whose content is:   database_host: postgres.production.svc.cluster.local
# 2. Mount the ConfigMap so the file appears at /etc/app/config.yaml in the container
#    (update the manifest and recreate the pod)
# 3. Verify the pod starts and stays Running
