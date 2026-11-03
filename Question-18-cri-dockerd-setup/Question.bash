# Question 18 - CRI-dockerd Installation from the release binary  (Cluster Architecture | Medium | 15 min)
#
# Do this on the worker node:  ssh node01
#
# Tasks
# 1. Load the required kernel modules: overlay and br_netfilter
# 2. Configure kernel networking parameters via sysctl (persistently, in /etc/sysctl.d/):
#    net.bridge.bridge-nf-call-iptables = 1, net.ipv4.ip_forward = 1, net.ipv6.conf.all.forwarding = 1
# 3. Install Docker (required dependency for CRI-dockerd) - skip if docker is already installed
# 4. Download and install the CRI-dockerd binary (v0.3.20 .tgz) from GitHub releases to /usr/local/bin
# 5. Create systemd unit files for cri-docker.service and cri-docker.socket
# 6. Enable and start the cri-docker services
# 7. Verify the CRI-dockerd socket is listening at /run/cri-dockerd.sock
