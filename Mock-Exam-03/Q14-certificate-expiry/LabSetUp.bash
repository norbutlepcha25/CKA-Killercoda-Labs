#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock3/14
echo "Q14 ready."
