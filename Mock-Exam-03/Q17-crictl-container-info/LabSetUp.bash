#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns project-puma >/dev/null
kubectl create deployment puma-for-rent-web -n project-puma --image=httpd:2-alpine --replicas=2 >/dev/null
mkdir -p /root/mock3/17
echo "Q17 ready: namespace project-puma"
