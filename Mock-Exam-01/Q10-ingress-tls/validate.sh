#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 01 - Question 10"
I="ingress api-ingress -n default"
check "Ingress api-ingress exists" kubectl get $I
eq "api-ingress class" "$(jp '{.spec.ingressClassName}' $I)" nginx
eq "api-ingress TLS secret" "$(jp '{.spec.tls[0].secretName}' $I)" api-tls-cert
if jp '{.spec.tls[0].hosts}' $I | grep -q api.example.com; then pass "TLS host api.example.com"; else fail "TLS hosts do not include api.example.com"; fi
R=$(jp '{range .spec.rules[*]}{.host}{range .http.paths[*]}|{.path}|{.pathType}|{.backend.service.name}:{.backend.service.port.number}{end}{"\n"}{end}' $I)
if echo "$R" | grep -q '^api.example.com.*|/api|Prefix|api:80'; then pass "rule api.example.com /api Prefix -> api:80"; else fail "rule for /api is not as required ($R)"; fi
IP=$(jp '{.status.addresses[?(@.type=="InternalIP")].address}' node "$(cp_node)")
HP=$(jp '{.spec.ports[?(@.name=="http")].nodePort}' svc ingress-nginx-controller -n ingress-nginx)
SP=$(jp '{.spec.ports[?(@.name=="https")].nodePort}' svc ingress-nginx-controller -n ingress-nginx)
C(){ curl -sk -m5 -o /dev/null -w '%{http_code}' --resolve "api.example.com:$2:$IP" "$1://api.example.com:$2$3"; }
sleep 3
eq "HTTPS /api/ -> 200" "$(C https $SP /api/)" 200
CN=$(echo | openssl s_client -connect $IP:$SP -servername api.example.com 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)
if echo "$CN" | grep -q api.example.com; then pass "HTTPS serves the api-tls-cert certificate"; else fail "HTTPS does not serve the api.example.com certificate ($CN)"; fi
eq "HTTP /api/ is redirected (308)" "$(C http $HP /api/)" 308
eq "HTTP /health answered directly (200)" "$(C http $HP /health)" 200
summary
