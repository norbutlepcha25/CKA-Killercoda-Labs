# ---- Scenario A: kubelet ----
kubectl get nodes                              # node01 NotReady
ssh node01
  systemctl status kubelet                     # inactive (dead), disabled
  journalctl -u kubelet --no-pager | tail -20
  systemctl enable --now kubelet               # enable = survives reboot
  exit
kubectl get nodes                              # node01 Ready

# ---- Scenario B: CoreDNS ----
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # fails
kubectl get pods -n kube-system -l k8s-app=kube-dns        # no pods
kubectl get endpoints kube-dns -n kube-system              # no endpoints
kubectl get deploy coredns -n kube-system                  # 0/0 replicas
kubectl scale deploy coredns -n kube-system --replicas=2
kubectl get pods -n kube-system -l k8s-app=kube-dns        # CrashLoopBackOff
kubectl logs -n kube-system -l k8s-app=kube-dns            # Unknown directive 'kubernetess'
kubectl edit cm coredns -n kube-system                     # kubernetess -> kubernetes
kubectl rollout restart deploy coredns -n kube-system
kubectl get endpoints kube-dns -n kube-system              # IPs listed
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # works

# ---- Scenario C: kube-proxy ----
kubectl get ds kube-proxy -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=20
kubectl get cm kube-proxy -n kube-system -o yaml
iptables-save | grep -c KUBE

# ---- Scenario D: audit logs ----
grep -i audit /etc/kubernetes/manifests/kube-apiserver.yaml   # nothing on Killercoda
# To enable you would add, for example:
#   - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxage=7
# plus hostPath volumes + volumeMounts for the policy file and the log directory.
# Then: tail /var/log/kubernetes/audit/audit.log | jq 'select(.responseStatus.code>=400)'
