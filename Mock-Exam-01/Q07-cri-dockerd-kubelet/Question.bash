# Mock Exam 01 - Question 07 - Container Runtime Configuration  (Cluster Architecture | 8 min)
#
# The worker node node01 must use cri-dockerd instead of containerd.
# Docker and cri-dockerd are already installed and running on node01
# (cri-docker.socket / cri-docker.service, socket unix:///run/cri-dockerd.sock).
#
# Tasks
# 1. Configure the kubelet on node01 to use the cri-dockerd socket and restart it
# 2. Verify node01 is Ready and reports a docker:// container runtime
# 3. Verify that a pod scheduled to node01 starts
#
# This changes node01 for the rest of the session. ./mock.sh 1 7 cleanup switches it back.
