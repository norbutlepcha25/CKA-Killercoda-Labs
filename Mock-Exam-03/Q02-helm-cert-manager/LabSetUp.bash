#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_helm
helm repo add jetstack https://charts.jetstack.io --force-update >/dev/null
helm repo update jetstack >/dev/null
mkdir -p /root/mock3/2
cat > /root/mock3/2/cluster-issuer.yaml <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: course-issuer
spec:
  selfSigned: {}
YAML
echo "Q02 ready: helm repo jetstack added, /root/mock3/2/cluster-issuer.yaml written."
