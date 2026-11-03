kubectl get nodes                                           # connection refused
crictl ps -a | grep kube-apiserver                          # Exited / restarting
crictl logs $(crictl ps -a --name kube-apiserver -q | head -1) 2>&1 | tail -20
#   ... dial tcp 10.0.0.5:2379: connect: connection refused / i/o timeout
ls /var/log/pods/ | grep apiserver                          # alternative log location
grep etcd-servers /etc/kubernetes/manifests/kube-apiserver.yaml
grep -E "listen-client-urls|advertise-client-urls" /etc/kubernetes/manifests/etcd.yaml
#   --listen-client-urls=https://127.0.0.1:2379,https://<node-ip>:2379
sed -i 's#--etcd-servers=.*#--etcd-servers=https://127.0.0.1:2379#' /etc/kubernetes/manifests/kube-apiserver.yaml
watch crictl ps --name kube-apiserver                       # Running after ~30-60s
kubectl get nodes
kubectl get pods -A
