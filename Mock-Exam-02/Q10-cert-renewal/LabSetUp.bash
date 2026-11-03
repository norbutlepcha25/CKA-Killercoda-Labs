#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2 /root/.cka-lab
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate | cut -d= -f2 > /root/.cka-lab/mock2-q10-old-enddate
echo "Q10 ready: apiserver.crt currently expires $(cat /root/.cka-lab/mock2-q10-old-enddate)."
