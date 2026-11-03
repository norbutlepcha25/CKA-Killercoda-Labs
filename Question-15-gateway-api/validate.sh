#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-15; GW="gateway web-gateway -n $NS"; RT="httproute web-route -n $NS"
banner "Validating Question 15"
check "namespace $NS exists" kubectl get ns $NS
eq "deployment web 2 ready replicas" "$(jp '{.status.readyReplicas}' deploy web -n $NS)" 2
eq "deployment web image nginx:1.28" "$(jp '{.spec.template.spec.containers[0].image}' deploy web -n $NS)" nginx:1.28
eq "service web-svc type ClusterIP" "$(jp '{.spec.type}' svc web-svc -n $NS)" ClusterIP
eq "service web-svc port 80" "$(jp '{.spec.ports[0].port}' svc web-svc -n $NS)" 80
GC=$(jp '{.spec.gatewayClassName}' $GW)
if [ -n "$GC" ] && kubectl get gatewayclass "$GC" >/dev/null 2>&1; then pass "Gateway uses existing GatewayClass $GC"; else fail "Gateway web-gateway missing or GatewayClass '$GC' not found"; fi
eq "listener port 80" "$(jp '{.spec.listeners[0].port}' $GW)" 80
eq "listener protocol HTTP" "$(jp '{.spec.listeners[0].protocol}' $GW)" HTTP
eq "Gateway Accepted" "$(jp '{.status.conditions[?(@.type=="Accepted")].status}' $GW)" True
P=$(jp '{.status.conditions[?(@.type=="Programmed")].status}' $GW)
if [ "$P" = True ]; then pass "Gateway Programmed: True"; else warn "Gateway Programmed is '$P' (on NodePort it can take a minute)"; fi
eq "HTTPRoute parent is web-gateway" "$(jp '{.spec.parentRefs[0].name}' $RT)" web-gateway
eq "HTTPRoute path PathPrefix /" "$(jp '{.spec.rules[0].matches[0].path.type} {.spec.rules[0].matches[0].path.value}' $RT)" "PathPrefix /"
eq "HTTPRoute backend web-svc:80" "$(jp '{.spec.rules[0].backendRefs[0].name}:{.spec.rules[0].backendRefs[0].port}' $RT)" web-svc:80
eq "HTTPRoute Accepted by the Gateway" "$(jp '{.status.parents[0].conditions[?(@.type=="Accepted")].status}' $RT)" True
eq "HTTPRoute ResolvedRefs" "$(jp '{.status.parents[0].conditions[?(@.type=="ResolvedRefs")].status}' $RT)" True
SVC=$(jp '{.items[0].metadata.name}' svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway,gateway.envoyproxy.io/owning-gateway-namespace=$NS)
NP=$(jp '{.spec.ports[?(@.port==80)].nodePort}' svc "$SVC" -n envoy-gateway-system)
IP=$(jp '{.items[0].status.addresses[?(@.type=="InternalIP")].address}' nodes)
if [ -n "$NP" ] && [ "$(curl -s -m5 -o /dev/null -w '%{http_code}' http://$IP:$NP/)" = 200 ]; then pass "HTTP 200 through the gateway ($IP:$NP)"; else fail "no HTTP 200 through the gateway"; fi
summary
