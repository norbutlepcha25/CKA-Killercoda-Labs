#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 13"
NS=project-r500; RT="httproute traffic-director -n $NS"
check "HTTPRoute traffic-director exists" kubectl get $RT
eq "HTTPRoute parent is Gateway main" "$(jp '{.spec.parentRefs[0].name}' $RT)" main
eq "HTTPRoute Accepted" "$(jp '{.status.parents[0].conditions[?(@.type=="Accepted")].status}' $RT)" True
SVC=$(jp '{.items[0].metadata.name}' svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=main,gateway.envoyproxy.io/owning-gateway-namespace=$NS)
NP=$(jp '{.spec.ports[?(@.port==80)].nodePort}' svc "$SVC" -n envoy-gateway-system)
IP=$(jp "{.status.addresses[?(@.type==\"InternalIP\")].address}" node $(cp_node))
sleep 3
get(){ curl -s -m5 -H "Host: r500.gateway" "$@" 2>/dev/null | tr -d '\r\n'; }
eq "/desktop -> desktop" "$(get http://$IP:$NP/desktop)" "Web Desktop App"
eq "/mobile -> mobile" "$(get http://$IP:$NP/mobile)" "Web Mobile App"
eq "/auto with User-Agent mobile -> mobile" "$(get -H 'User-Agent: mobile' http://$IP:$NP/auto)" "Web Mobile App"
eq "/auto with default User-Agent -> desktop" "$(get http://$IP:$NP/auto)" "Web Desktop App"
eq "/auto with User-Agent mobile-x -> desktop (exact match)" "$(get -H 'User-Agent: mobile-x' http://$IP:$NP/auto)" "Web Desktop App"
C=$(curl -s -m5 -o /dev/null -w '%{http_code}' -H "Host: r500.gateway" http://$IP:$NP/other)
eq "unknown path is not routed" "$C" 404
summary
