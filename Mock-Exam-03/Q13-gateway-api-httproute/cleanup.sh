#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
del_ns project-r500
sed -i '/ r500.gateway$/d' /etc/hosts 2>/dev/null
rm -rf /root/mock3/13
true
