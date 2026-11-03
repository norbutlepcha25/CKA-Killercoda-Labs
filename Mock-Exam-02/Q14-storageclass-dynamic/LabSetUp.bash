#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_local_path
kubectl create ns storage-demo >/dev/null
echo "Q14 ready: namespace storage-demo exists."
