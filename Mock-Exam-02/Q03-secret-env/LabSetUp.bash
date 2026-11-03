#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns secrets-demo >/dev/null
kubectl create deployment app-deploy -n secrets-demo --image=busybox:1.37 -- sh -c 'echo app started; sleep 36000' >/dev/null
kubectl patch deploy app-deploy -n secrets-demo --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/name","value":"app"}]' >/dev/null
echo "Q03 ready: Deployment secrets-demo/app-deploy."
