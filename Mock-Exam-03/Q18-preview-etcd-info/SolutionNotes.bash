kubectl -n kube-system get pod | grep etcd                      # static Pod
grep -E -- '--(key-file|cert-file|client-cert-auth)=' /etc/kubernetes/manifests/etcd.yaml
openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt
cat > /root/mock3/18/etcd-info.txt <<TXT
Server private key location: /etc/kubernetes/pki/etcd/server.key
Server certificate expiration date: $(openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt | cut -d= -f2)
Is client certificate authentication enabled: yes
TXT
