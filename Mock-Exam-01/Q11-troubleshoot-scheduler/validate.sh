#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 11"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
BAD=""; for f in $(grep -o -- '-kubeconfig=[^ "]*' $M | cut -d= -f2); do [ -f "$f" ] || BAD="$BAD $f"; done
if [ -z "$BAD" ]; then pass "all kubeconfig paths in kube-scheduler.yaml exist"; else fail "missing kubeconfig file(s):$BAD"; fi
ls /etc/kubernetes/manifests/ | grep -vE '^(etcd|kube-apiserver|kube-controller-manager|kube-scheduler)\.yaml$' | grep -q . && warn "extra files in /etc/kubernetes/manifests: $(ls /etc/kubernetes/manifests | tr '\n' ' ')"
OK=0; for i in $(seq 1 20); do crictl ps --name kube-scheduler --state running -q 2>/dev/null | grep -q . && { OK=1; break; }; sleep 3; done
if [ $OK = 1 ]; then pass "kube-scheduler container Running"; else fail "kube-scheduler container is not running"; fi
eq "kube-scheduler pod Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' pod kube-scheduler-$(cp_node) -n kube-system)" True
if kubectl wait --for=condition=PodScheduled pod/sched-test --timeout=60s >/dev/null 2>&1; then pass "sched-test was scheduled"; else fail "sched-test is still not scheduled"; fi
nonempty "root cause written to /root/mock1/q11-cause.txt" "$(filecontent /root/mock1/q11-cause.txt)"
summary
