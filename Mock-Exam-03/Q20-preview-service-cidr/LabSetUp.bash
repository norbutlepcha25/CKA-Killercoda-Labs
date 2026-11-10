#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
apiserver_reset || exit 1
KCM=/etc/kubernetes/manifests/kube-controller-manager.yaml; KCMP=/root/.cka-lab/mock3-kcm.pristine.yaml
[ -f $KCMP ] || cp $KCM $KCMP
mkdir -p /root/mock3/20
echo "Q20 ready. Clean copies: $APISERVER_PRISTINE and $KCMP"
