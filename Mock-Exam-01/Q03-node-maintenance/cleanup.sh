#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl uncordon "$(worker_node)" >/dev/null 2>&1
del_ns maintenance
rm -f /root/.cka-lab/mock1-q03-db-uid
true
