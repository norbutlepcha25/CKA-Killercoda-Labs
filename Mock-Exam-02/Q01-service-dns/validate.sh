#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 01"
eq "FQDN in q01-fqdn.txt" "$(filecontent /root/mock2/q01-fqdn.txt | sed 's/\.$//')" web-ui.frontend.svc.cluster.local
eq "pod dns-test Running in backend" "$(jp '{.status.phase}' pod dns-test -n backend)" Running
eq "dns-test image" "$(jp '{.spec.containers[0].image}' pod dns-test -n backend)" busybox:1.37
eq "IP in q01-ip.txt is the Service ClusterIP" "$(filecontent /root/mock2/q01-ip.txt)" "$(jp '{.spec.clusterIP}' svc web-ui -n frontend)"
check "dns-test resolves web-ui.frontend" kubectl exec dns-test -n backend -- nslookup web-ui.frontend.svc.cluster.local
eq "dns-test gets an answer from web-ui.frontend:3000" "$(kubectl exec dns-test -n backend -- wget -qO- -T 5 http://web-ui.frontend:3000 2>/dev/null)" "hello from web-ui"
summary
