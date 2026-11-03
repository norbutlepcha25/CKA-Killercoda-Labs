#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
rm -f /etc/kubernetes/manifests/static-web.yaml
true
