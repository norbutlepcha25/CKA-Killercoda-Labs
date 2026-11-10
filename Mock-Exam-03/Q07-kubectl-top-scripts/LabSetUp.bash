#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_metrics_server
mkdir -p /root/mock3/7
echo "Q07 ready: metrics-server is running."
