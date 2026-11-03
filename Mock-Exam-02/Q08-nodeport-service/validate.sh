#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 02 - Question 08"
S="svc legacy-app -n legacy"
eq "type NodePort" "$(jp '{.spec.type}' $S)" NodePort
eq "port 8080 -> 3000, nodePort 30080" "$(jp '{.spec.ports[0].port}->{.spec.ports[0].targetPort}/{.spec.ports[0].nodePort}' $S)" "8080->3000/30080"
eq "selector app=legacy" "$(jp '{.spec.selector.app}' $S)" legacy
nonempty "Service has endpoints" "$(jp '{.items[*].endpoints[*].addresses[*]}' endpointslices -n legacy -l kubernetes.io/service-name=legacy-app)"
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  IP=$(jp '{.status.addresses[?(@.type=="InternalIP")].address}' node $n)
  eq "http://$IP:30080 ($n) answers" "$(curl -s -m5 http://$IP:30080 2>/dev/null)" "legacy-app OK"
done
summary
