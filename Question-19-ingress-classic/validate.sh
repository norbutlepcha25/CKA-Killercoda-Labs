#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-19; I="ingress app-ingress -n $NS"
banner "Validating Question 19"
for d in web-app api-app; do
  eq "deployment $d 2 ready" "$(jp '{.status.readyReplicas}' deploy $d -n $NS)" 2
  eq "deployment $d image nginx:1.28" "$(jp '{.spec.template.spec.containers[0].image}' deploy $d -n $NS)" nginx:1.28
done
eq "web-service ClusterIP port 80" "$(jp '{.spec.type}:{.spec.ports[0].port}' svc web-service -n $NS)" ClusterIP:80
eq "api-service ClusterIP port 8080" "$(jp '{.spec.type}:{.spec.ports[0].port}' svc api-service -n $NS)" ClusterIP:8080
nonempty "web-service has endpoints" "$(jp '{.subsets[*].addresses[*].ip}' endpoints web-service -n $NS)"
nonempty "api-service has endpoints" "$(jp '{.subsets[*].addresses[*].ip}' endpoints api-service -n $NS)"
eq "ingressClassName nginx" "$(jp '{.spec.ingressClassName}' $I)" nginx
eq "defaultBackend web-service:80" "$(jp '{.spec.defaultBackend.service.name}:{.spec.defaultBackend.service.port.number}' $I)" web-service:80
eq "path / -> web-service:80" "$(jp '{.spec.rules[0].http.paths[?(@.path=="/")].backend.service.name}:{.spec.rules[0].http.paths[?(@.path=="/")].backend.service.port.number}' $I)" web-service:80
eq "path /api -> api-service:8080" "$(jp '{.spec.rules[0].http.paths[?(@.path=="/api")].backend.service.name}:{.spec.rules[0].http.paths[?(@.path=="/api")].backend.service.port.number}' $I)" api-service:8080
A=$(jp '{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}' $I)
if [ -n "$A" ]; then pass "Ingress has address $A"; else warn "Ingress has no address yet (can take ~1 min)"; fi
NP=$(jp '{.spec.ports[?(@.port==80)].nodePort}' svc ingress-nginx-controller -n ingress-nginx)
IP=$(jp '{.items[0].status.addresses[?(@.type=="InternalIP")].address}' nodes)
eq "curl / through the ingress controller returns 200" "$(curl -s -m5 -o /dev/null -w '%{http_code}' http://$IP:$NP/)" 200
summary
