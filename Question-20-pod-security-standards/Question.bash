# Question 20 - Pod Security Standards  (Cluster Architecture | Medium | 15 min)
#
# Tasks
# 1. Create a namespace called exercise-20
# 2. Label it with Pod Security Standards at restricted level in enforce mode
# 3. Attempt to run a pod with a privileged container in exercise-20 - it should be rejected
# 4. Create a second namespace exercise-20-baseline with baseline PSS level (enforce)
# 5. Run a pod named safe-pod (busybox:1.36, sleep 3600) with runAsNonRoot: true and runAsUser: 1000
#    in the baseline namespace - it should succeed
# 6. Run a pod with privileged: true in the baseline namespace - it should be rejected
# 7. Create a third namespace exercise-20-audit with restricted level in audit and warn mode only (no enforce)
# 8. Run a privileged pod named audit-pod (nginx:1.28) in exercise-20-audit - it should succeed,
#    but kubectl prints a warning and the violation is recorded in the API audit log
# 9. Note the warning returned when the pod was created in audit/warn mode
