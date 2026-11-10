find /etc/kubernetes/pki | grep apiserver
openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -A2 Validity
openssl x509 -noout -enddate -in /etc/kubernetes/pki/apiserver.crt | cut -d= -f2 > /root/mock3/14/expiration
kubeadm certs check-expiration | grep apiserver          # same date
echo "kubeadm certs renew apiserver" > /root/mock3/14/kubeadm-renew-certs.sh
