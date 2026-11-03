# 1. logs - kubectl works while the API server is up; crictl works even when it is down
kubectl logs -n kube-system kube-apiserver-controlplane --tail=50 > /root/mock2/q05-apiserver.log
#   or: crictl logs --tail=50 $(crictl ps --name kube-apiserver -q) > /root/mock2/q05-apiserver.log 2>&1
#   (kubeadm runs it as a static pod - there is no kube-apiserver systemd unit to journalctl)
# 2. listening socket
ss -tlnp | grep 6443 > /root/mock2/q05-listen.txt            # ... *:6443 ... users:(("kube-apiserver",pid=...))
# 3. health
kubectl get --raw='/readyz?verbose' > /root/mock2/q05-readyz.txt
# 4. who sends the most requests? The audit log is JSON lines - one event per line.
jq -r '.user.username' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head -5
#   without jq: grep -o '"username":"[^"]*"' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head
echo system:serviceaccount:reports:report-bot > /root/mock2/q05-top-user.txt
# 5. response codes for that user
grep 'system:serviceaccount:reports:report-bot' /var/log/kubernetes/audit/audit.log | jq -r '.responseStatus.code' | sort | uniq -c
echo 403 > /root/mock2/q05-code.txt
# 6. the username says: ServiceAccount report-bot in namespace reports
kubectl get deploy -n reports -o wide
kubectl scale deploy report-bot -n reports --replicas=0
# Also useful: kubectl get --raw /metrics | grep apiserver_request_total, and APF:
# kubectl get --raw /debug/api_priority_and_fairness/dump_priority_levels
