#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
CP=$(cp_node); W=$(worker_node)
CUR=$(kubeadm version -o short)                         # e.g. v1.35.1
MM=$(echo "$CUR" | sed 's/^v//' | cut -d. -f1,2)        # e.g. 1.35
NEXT="1.$(( ${MM#1.} + 1 ))"
if curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$NEXT/deb/Release.key" -o /dev/null 2>/dev/null; then T=$NEXT; else T=$MM; fi
echo "Current version: $CUR  -> preparing apt repository for v$T on $CP and $W ..."
REPO="mkdir -p /etc/apt/keyrings && curl -fsSL https://pkgs.k8s.io/core:/stable:/v$T/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-cka-lab.gpg && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-cka-lab.gpg] https://pkgs.k8s.io/core:/stable:/v$T/deb/ /' > /etc/apt/sources.list.d/kubernetes-cka-lab.list && apt-get update -qq >/dev/null 2>&1"
on_node "$CP" "$REPO" || { echo "Could not configure the apt repo on $CP"; exit 1; }
on_node "$W" "$REPO"  || { echo "Could not configure the apt repo on $W"; exit 1; }
PKG=$(apt-cache madison kubeadm | awk '{print $3}' | grep "^$T\." | sort -V | tail -1)
VER="v${PKG%-*}"
if [ -z "$PKG" ] || [ "$VER" = "$CUR" ]; then
  echo "No newer kubeadm version than $CUR is available - this cluster is already on the latest release."; exit 1
fi
echo "$VER" > /root/upgrade-target.txt
echo "$PKG" > /root/upgrade-target-package.txt
echo "Lab ready. Target version: $VER  (apt package version: $PKG)"
echo "Saved to /root/upgrade-target.txt and /root/upgrade-target-package.txt"
