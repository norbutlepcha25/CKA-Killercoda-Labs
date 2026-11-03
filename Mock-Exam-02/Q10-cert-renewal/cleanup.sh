#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
rm -f /root/mock2/q10-before.txt /root/.cka-lab/mock2-q10-old-enddate
true
