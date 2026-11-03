mkdir -p /etc/kubernetes/audit /var/log/kubernetes/audit
cat <<'EOF' > /etc/kubernetes/audit/policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"]
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["configmaps"]
- level: None
EOF
# Edit /etc/kubernetes/manifests/kube-apiserver.yaml (keep any backup OUTSIDE the manifests dir):
#   command:
#   - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxbackup=2
#   - --audit-log-maxsize=10
#   volumeMounts:
#   - name: audit-policy
#     mountPath: /etc/kubernetes/audit
#     readOnly: true
#   - name: audit-log
#     mountPath: /var/log/kubernetes/audit
#   volumes:
#   - name: audit-policy
#     hostPath: {path: /etc/kubernetes/audit, type: DirectoryOrCreate}
#   - name: audit-log
#     hostPath: {path: /var/log/kubernetes/audit, type: DirectoryOrCreate}
# The same edit with sed:
M=/etc/kubernetes/manifests/kube-apiserver.yaml
cp $M /root/kube-apiserver.yaml.bak
sed -i '/- kube-apiserver$/a\    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml\n    - --audit-log-path=/var/log/kubernetes/audit/audit.log\n    - --audit-log-maxbackup=2\n    - --audit-log-maxsize=10' $M
sed -i '0,/^    volumeMounts:$/s##    volumeMounts:\n    - mountPath: /etc/kubernetes/audit\n      name: audit-policy\n      readOnly: true\n    - mountPath: /var/log/kubernetes/audit\n      name: audit-log#' $M
sed -i '0,/^  volumes:$/s##  volumes:\n  - hostPath:\n      path: /etc/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-policy\n  - hostPath:\n      path: /var/log/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-log#' $M
# wait until the API server is back (30-90s)
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
until grep -q 'serviceaccount:ops' /var/log/kubernetes/audit/audit.log 2>/dev/null; do sleep 5; done
# Each line of the audit log is one JSON event (JSON lines, not one big array):
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | tail -3
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | grep -v system:node: \
  | jq -r '[.user.username, .verb, .responseStatus.code, .requestReceivedTimestamp] | @tsv' | sort | uniq -c | tail
L=$(grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep 'system:serviceaccount:ops:config-sync' | tail -1)
echo "$L" | jq -r .user.username > /root/mock1/q08-user.txt          # system:serviceaccount:ops:config-sync
echo "$L" | jq -r .responseStatus.code > /root/mock1/q08-code.txt     # 403 - it has no RBAC permission
echo "$L" | jq -r .requestReceivedTimestamp > /root/mock1/q08-time.txt
