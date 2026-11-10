#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 09"
NS=project-swan
eq "Pod api-contact image" "$(jp '{.spec.containers[0].image}' pod api-contact -n $NS)" nginx:1-alpine
eq "Pod api-contact ServiceAccount" "$(jp '{.spec.serviceAccountName}' pod api-contact -n $NS)" secret-reader
eq "Pod api-contact Running" "$(jp '{.status.phase}' pod api-contact -n $NS)" Running
F=/root/mock3/9/result.json
if python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get("kind")=="SecretList" else 1)' $F 2>/dev/null; then pass "result.json is a SecretList (valid JSON)"; else fail "result.json missing, not JSON or not a SecretList"; fi
if python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if any(i["metadata"]["name"]=="read-me" for i in d.get("items",[])) else 1)' $F 2>/dev/null; then pass "result.json contains Secret read-me"; else fail "result.json does not contain Secret read-me"; fi
summary
