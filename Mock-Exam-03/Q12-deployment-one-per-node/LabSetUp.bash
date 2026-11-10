#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-jaguar >/dev/null
echo "Q12 ready: namespace project-jaguar"
