#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
W=$(worker_node)
if on_node "$W" "command -v docker" >/dev/null 2>&1; then D="installed"; else D="NOT installed"; fi
echo "Lab ready. Do this exercise on the worker node:  ssh $W   (Docker is currently $D there)"
echo "Tip: this changes the node's runtime setup - best done in a fresh Killercoda session."
