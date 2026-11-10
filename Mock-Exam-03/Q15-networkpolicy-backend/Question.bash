# Mock Exam 03 - Question 15 - NetworkPolicy  (Services & Networking | 6%)
#
# An intruder got into the whole cluster from one hacked backend Pod. To prevent this, create
# NetworkPolicy np-backend in Namespace project-snake that allows the backend-* Pods ONLY to:
# - connect to db1-* Pods on port 1111
# - connect to db2-* Pods on port 2222
# Use the app Pod labels in your policy.
#
# All Pods run nginx, so you can test with: kubectl -n project-snake exec POD -- curl -s POD_IP:PORT
# After your change, backend -> vault-* on port 3333 must no longer work.
