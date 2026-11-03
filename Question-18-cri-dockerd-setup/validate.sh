#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node); R(){ on_node "$W" "$1" 2>/dev/null; }
banner "Validating Question 18 (on $W)"
if R "lsmod | grep -qw overlay"; then pass "overlay module loaded"; else fail "overlay module not loaded"; fi
if R "lsmod | grep -qw br_netfilter"; then pass "br_netfilter module loaded"; else fail "br_netfilter module not loaded"; fi
eq "net.bridge.bridge-nf-call-iptables = 1" "$(R 'sysctl -n net.bridge.bridge-nf-call-iptables')" 1
eq "net.ipv4.ip_forward = 1" "$(R 'sysctl -n net.ipv4.ip_forward')" 1
eq "net.ipv6.conf.all.forwarding = 1" "$(R 'sysctl -n net.ipv6.conf.all.forwarding')" 1
if R "grep -rqs 'bridge-nf-call-iptables *= *1' /etc/sysctl.d/ /etc/sysctl.conf"; then pass "sysctl settings persisted"; else fail "sysctl settings not persisted in /etc/sysctl.d/"; fi
eq "docker service active" "$(R 'systemctl is-active docker')" active
if R "test -x /usr/local/bin/cri-dockerd"; then pass "/usr/local/bin/cri-dockerd installed"; else fail "/usr/local/bin/cri-dockerd not found"; fi
eq "cri-docker.service active" "$(R 'systemctl is-active cri-docker.service')" active
eq "cri-docker.service enabled" "$(R 'systemctl is-enabled cri-docker.service')" enabled
eq "cri-docker.socket active" "$(R 'systemctl is-active cri-docker.socket')" active
eq "cri-docker.socket enabled" "$(R 'systemctl is-enabled cri-docker.socket')" enabled
if R "test -S /run/cri-dockerd.sock"; then pass "/run/cri-dockerd.sock exists"; else fail "/run/cri-dockerd.sock missing"; fi
if R "crictl --runtime-endpoint unix:///run/cri-dockerd.sock version" | grep -qi docker; then pass "crictl talks to cri-dockerd"; else fail "crictl cannot reach cri-dockerd"; fi
summary
