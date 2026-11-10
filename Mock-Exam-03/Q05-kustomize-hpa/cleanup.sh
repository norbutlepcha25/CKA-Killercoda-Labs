#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns api-gateway-staging api-gateway-prod
rm -rf /root/mock3/5
true
