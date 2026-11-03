# Mock Exam 02 - Question 13 - Pod Security Exceptions  (Cluster Architecture | 9 min)
#
# Namespace restricted enforces the restricted Pod Security Standard. A legacy pod root-app
# (image nginx:1.27, must run as root) is rejected there.
#
# Pod Security Admission has no per-pod exemption label: exemptions exist only in the API server's
# admission configuration (by user, runtimeClass or namespace). Solve it with namespaces instead:
#
# Tasks
# 1. Create namespace legacy-root that enforces the baseline Pod Security Standard
#    (root is allowed, privileged containers are not)
# 2. Run pod root-app (nginx:1.27) there and verify it runs as uid 0
# 3. Leave namespace restricted unchanged: it must still reject a root pod
