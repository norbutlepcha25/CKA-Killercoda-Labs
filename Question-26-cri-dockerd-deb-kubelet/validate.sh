#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node); R(){ on_node "$W" "$1" 2>/dev/null; }
banner "Validating Question 26 (on $W)"
if R "dpkg -s cri-dockerd" | grep -q 'Status: install ok installed'; then pass "cri-dockerd package installed"; else fail "cri-dockerd package not installed"; fi
if R "lsmod | grep -qw overlay"; then pass "overlay module loaded"; else fail "overlay module not loaded"; fi
if R "lsmod | grep -qw br_netfilter"; then pass "br_netfilter module loaded"; else fail "br_netfilter module not loaded"; fi
eq "net.ipv4.ip_forward = 1" "$(R 'cat /proc/sys/net/ipv4/ip_forward')" 1
if R "grep -rqs 'ip_forward *= *1' /etc/sysctl.d/ /etc/sysctl.conf"; then pass "ip_forward persisted"; else fail "ip_forward not persisted in /etc/sysctl.d/ or /etc/sysctl.conf"; fi
eq "cri-docker.service active" "$(R 'systemctl is-active cri-docker.service')" active
eq "cri-docker.service enabled" "$(R 'systemctl is-enabled cri-docker.service')" enabled
if R "test -S /run/cri-dockerd.sock"; then pass "/run/cri-dockerd.sock exists"; else fail "/run/cri-dockerd.sock missing"; fi
if R "cat /var/lib/kubelet/kubeadm-flags.env /etc/default/kubelet" | grep -q 'cri-dockerd.sock'; then pass "kubelet configured with the cri-dockerd endpoint"; else fail "kubelet is not pointed at cri-dockerd.sock"; fi
eq "node $W Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $W)" True
RT=$(jp '{.status.nodeInfo.containerRuntimeVersion}' node $W)
if echo "$RT" | grep -q '^docker://'; then pass "node runtime is $RT"; else fail "node runtime is '$RT' (expected docker://...)"; fi
summary
