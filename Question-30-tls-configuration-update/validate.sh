#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-30
banner "Validating Question 30"
C=$(jp '{.data.nginx\.conf}' cm tls-config -n $NS | grep ssl_protocols)
if echo "$C" | grep -q 'TLSv1.2' && echo "$C" | grep -q 'TLSv1.3'; then pass "ConfigMap enables TLSv1.2 and TLSv1.3"; else fail "ConfigMap ssl_protocols is '$C'"; fi
eq "deployment tls-web ready" "$(jp '{.status.readyReplicas}' deploy tls-web -n $NS)" 1
IP=$(jp '{.spec.clusterIP}' svc tls-web -n $NS)
if curl -sk -m5 --tlsv1.2 --tls-max 1.2 "https://$IP" 2>/dev/null | grep -q 'Hello TLS'; then pass "TLS 1.2 connection works"; else fail "TLS 1.2 connection refused (did you restart the deployment?)"; fi
if curl -sk -m5 --tlsv1.3 "https://$IP" 2>/dev/null | grep -q 'Hello TLS'; then pass "TLS 1.3 connection works"; else fail "TLS 1.3 connection failed"; fi
summary
