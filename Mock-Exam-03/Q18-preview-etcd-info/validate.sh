#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 18"
M=/etc/kubernetes/manifests/etcd.yaml; F=/root/mock3/18/etcd-info.txt
KEY=$(grep -- '--key-file=' $M | head -1 | sed 's/.*--key-file=//')
CRT=$(grep -- '--cert-file=' $M | head -1 | sed 's/.*--cert-file=//')
CCA=$(grep -- '--client-cert-auth=' $M | head -1 | sed 's/.*--client-cert-auth=//')
val(){ grep -i "$1" $F 2>/dev/null | head -1 | sed 's/^[^:]*:[[:space:]]*//; s/[[:space:]]*$//'; }
eq "server private key location" "$(val 'private key')" "$KEY"
same_time "server certificate expiration" "$(val 'expiration')" "$(openssl x509 -noout -enddate -in $CRT | cut -d= -f2)"
A=$(val 'client certificate' | tr A-Z a-z); [ "$CCA" = true ] && E=yes || E=no
case "$A" in yes|true|enabled) A=yes;; no|false|disabled) A=no;; esac
eq "client certificate authentication" "$A" "$E"
summary
