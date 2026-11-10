# Mock Exam 03 - Question 02 - CRD, Helm, cert-manager  (Helm / CRDs | 6%)
#
# Install the cert-manager operator with Helm and create a ClusterIssuer for it.
# The Helm repo jetstack is already configured.
#
# 1. Create Namespace cert-manager
# 2. Install chart jetstack/cert-manager into that Namespace as release cert-manager,
#    with the value crds.enabled=true
# 3. Edit /root/mock3/2/cluster-issuer.yaml so that spec.selfSigned contains
#    crlDistributionPoints: ["http://example.com/crl"]
# 4. Create the ClusterIssuer from /root/mock3/2/cluster-issuer.yaml
#
# Issuing real certificates is not required.
