#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
echo "Lab ready. Work in the default namespace. (Question 24 also uses a PriorityClass called high-priority - its setup resets it.)"
