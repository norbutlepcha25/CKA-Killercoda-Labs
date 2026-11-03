#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
command -v helm >/dev/null && helm uninstall web -n exercise-13 >/dev/null 2>&1
del_ns exercise-13
true
