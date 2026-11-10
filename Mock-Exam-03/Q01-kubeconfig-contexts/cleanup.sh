#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
rm -rf /root/mock3/1 /root/.cka-lab/mock3-q1-expected.crt
true
