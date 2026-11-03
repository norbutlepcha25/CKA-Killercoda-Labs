#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
apiserver_reset >/dev/null 2>&1 || true
rm -rf /etc/kubernetes/audit /var/log/kubernetes/audit
del_ns reports
rm -f /root/mock2/q05-*
true
