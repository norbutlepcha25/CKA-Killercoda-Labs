#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
command -v helm >/dev/null && helm uninstall monitoring-stack -n monitoring >/dev/null 2>&1
del_ns monitoring
rm -rf /root/helm-charts/monitoring
true
