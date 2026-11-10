kubectl -n kube-system get deploy,cm | grep coredns
kubectl -n kube-system get cm coredns -o yaml > /root/mock3/16/coredns_backup.yaml
kubectl -n kube-system edit cm coredns
#   kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {     <- add custom-domain on this line
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system get pod -l k8s-app=kube-dns          # Running = no syntax error
kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
kubectl exec bb -- nslookup kubernetes.default.svc.custom-domain
kubectl exec bb -- nslookup kubernetes.default.svc.cluster.local
# restore if needed:
#   kubectl apply -f /root/mock3/16/coredns_backup.yaml   (or delete + apply) && kubectl -n kube-system rollout restart deploy coredns
