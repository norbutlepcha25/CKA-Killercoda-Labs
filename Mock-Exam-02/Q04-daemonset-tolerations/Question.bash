# Mock Exam 02 - Question 04 - DaemonSet Configuration  (Workloads & Scheduling | 8 min)
#
# DaemonSet monitoring-agent in namespace monitoring must run on every node, including the
# control plane. Right now the control plane node is missing its agent because of its taint.
#
# Tasks
# 1. Update the DaemonSet so it tolerates node-role.kubernetes.io/control-plane:NoSchedule
#    (keep the image busybox:1.37)
# 2. Verify one agent pod runs on every node
