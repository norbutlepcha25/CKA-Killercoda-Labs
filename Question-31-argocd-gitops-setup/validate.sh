#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 31"
check "namespace argocd exists" kubectl get ns argocd
check "Application CRD installed" kubectl get crd applications.argoproj.io
eq "argocd-server available" "$(jp '{.status.conditions[?(@.type=="Available")].status}' deploy argocd-server -n argocd)" True
NR=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -vc ' Running ')
eq "all argocd pods Running" "$NR" 0
if grep -q 'kind: Application' /root/argocd-app.yaml 2>/dev/null && grep -q 'path: guestbook' /root/argocd-app.yaml; then pass "/root/argocd-app.yaml saved"; else fail "/root/argocd-app.yaml missing or incomplete"; fi
A="application my-app -n argocd"
eq "Application source path guestbook" "$(jp '{.spec.source.path}' $A)" guestbook
eq "Application destination namespace default" "$(jp '{.spec.destination.namespace}' $A)" default
nonempty "automated sync enabled" "$(jp '{.spec.syncPolicy.automated}' $A)"
eq "Application Synced" "$(jp '{.status.sync.status}' $A)" Synced
H=$(jp '{.status.health.status}' $A)
if [ "$H" = Healthy ]; then pass "Application Healthy"; else warn "Application health is '$H' (pods may still be starting)"; fi
check "guestbook-ui deployed in default" kubectl get deploy guestbook-ui -n default
summary
