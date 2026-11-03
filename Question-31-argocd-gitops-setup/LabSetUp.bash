#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
echo "Lab ready. Argo CD is not installed. (It needs ~1.5 GB RAM - close other labs first.)"
