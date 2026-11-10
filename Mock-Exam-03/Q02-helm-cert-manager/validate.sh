#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 02"
check "namespace cert-manager exists" kubectl get ns cert-manager
if helm status cert-manager -n cert-manager 2>/dev/null | grep -q 'STATUS: deployed'; then pass "Helm release cert-manager deployed in cert-manager"; else fail "no deployed Helm release cert-manager in namespace cert-manager"; fi
if helm list -n cert-manager -o yaml 2>/dev/null | grep -q 'chart: cert-manager-'; then pass "release uses chart cert-manager"; else fail "release does not use chart cert-manager"; fi
if helm get values cert-manager -n cert-manager -a -o yaml 2>/dev/null | grep -A3 '^crds:' | grep -q 'enabled: true'; then pass "crds.enabled=true"; else fail "crds.enabled is not true"; fi
check "CRD clusterissuers.cert-manager.io exists" kubectl get crd clusterissuers.cert-manager.io
check "cert-manager webhook available" kubectl -n cert-manager wait --for=condition=Available deploy/cert-manager-webhook --timeout=30s
if grep -q 'http://example.com/crl' /root/mock3/2/cluster-issuer.yaml 2>/dev/null; then pass "file contains the CRL distribution point"; else fail "/root/mock3/2/cluster-issuer.yaml not updated"; fi
eq "ClusterIssuer course-issuer crlDistributionPoints" "$(jp '{.spec.selfSigned.crlDistributionPoints[*]}' clusterissuer course-issuer)" http://example.com/crl
eq "ClusterIssuer course-issuer Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' clusterissuer course-issuer)" True
summary
