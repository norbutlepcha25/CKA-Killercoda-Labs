#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
apiserver_reset >/dev/null 2>&1 || true
del_ns ops
rm -rf /etc/kubernetes/audit /var/log/kubernetes/audit /root/mock1/q08-*.txt
true
