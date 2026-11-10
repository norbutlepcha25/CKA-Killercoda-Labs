# Mock Exam 03 - Question 17 - Find Container of Pod and check info  (Troubleshooting | 3%)
#
# In Namespace project-puma create Pod tigers-reunite (image httpd:2-alpine) with labels
# pod=container and container=pod. Find out which node it runs on, ssh to that node and find the
# containerd container that belongs to the Pod.
#
# Using crictl:
# 1. Write the container ID and its info.runtimeType into /root/mock3/17/pod-container.txt
#    on controlplane, on one line:  <container-id> <runtimeType>
# 2. Write the container's logs into /root/mock3/17/pod-container.log on controlplane
