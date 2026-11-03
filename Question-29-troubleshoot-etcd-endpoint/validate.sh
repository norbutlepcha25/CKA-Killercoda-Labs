#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 29"
M=/etc/kubernetes/manifests/kube-apiserver.yaml; E=/etc/kubernetes/manifests/etcd.yaml
CUR=$(grep -- '--etcd-servers=' $M | sed 's/.*--etcd-servers=//' | tr -d ' "')
URLS=$(grep -E -- '--(listen|advertise)-client-urls=' $E | sed 's/.*=//' | tr ',' '\n' | tr -d ' "')
OK=1; for u in $(echo "$CUR" | tr ',' ' '); do echo "$URLS" | grep -qx "$u" || OK=0; done
if [ -n "$CUR" ] && [ $OK = 1 ]; then pass "--etcd-servers=$CUR matches etcd's client URLs"; else fail "--etcd-servers=$CUR does not match etcd client URLs ($(echo $URLS | tr '\n' ' '))"; fi
if echo "$CUR" | grep -q ':2380'; then fail "etcd-servers uses the peer port 2380"; fi
ls /etc/kubernetes/manifests/ | grep -vE '^(etcd|kube-apiserver|kube-controller-manager|kube-scheduler)\.yaml$' | grep -q . && warn "extra files in /etc/kubernetes/manifests: $(ls /etc/kubernetes/manifests | tr '\n' ' ')"
UP=0; for i in $(seq 1 20); do kubectl get nodes >/dev/null 2>&1 && { UP=1; break; }; sleep 3; done
if [ $UP = 1 ]; then pass "API server answers (kubectl get nodes works)"; else fail "API server is still not answering"; fi
if crictl ps --name kube-apiserver --state running -q 2>/dev/null | grep -q .; then pass "kube-apiserver container Running"; else fail "kube-apiserver container not running"; fi
check "kubectl get pods -A works" kubectl get pods -A
summary
