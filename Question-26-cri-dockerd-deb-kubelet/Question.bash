# Question 26 - CRI-dockerd from the .deb package + switch the kubelet  (Cluster Architecture | Hard | 30 min)
#
# Do this on the worker node:  ssh node01
# The lab setup downloaded the package to /root/cri-dockerd.deb on node01.
#
# Tasks
# 1. SSH into node01
# 2. Install cri-dockerd from /root/cri-dockerd.deb using dpkg
# 3. Configure the system for cri-dockerd:
#    - Enable IP forwarding with sysctl (persistently)
#    - Load the kernel modules overlay and br_netfilter
# 4. Enable and start the cri-docker service and socket
#    (the systemd units are called cri-docker.service / cri-docker.socket)
# 5. Verify the cri-dockerd socket /run/cri-dockerd.sock is available
# 6. Configure the kubelet on node01 to use cri-dockerd (unix:///run/cri-dockerd.sock)
# 7. Restart the kubelet and verify node01 is Ready and now reports a docker:// container runtime
#
# ./lab.sh 26 cleanup switches node01 back to containerd.
