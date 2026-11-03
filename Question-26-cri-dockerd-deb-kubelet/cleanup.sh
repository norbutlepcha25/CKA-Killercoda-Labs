#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node)
on_node "$W" "bash -s" < "$HERE/../lib/cri-reset.sh" >/dev/null 2>&1
true
