kubeadm certs check-expiration | tee /root/mock2/q10-before.txt
kubeadm certs renew all
#   "Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager,
#    kube-scheduler and etcd, so that they can use the new certificates."
kubeadm certs check-expiration                       # new dates
# Restart the static pods: move the manifests out, wait until the containers are gone, move them back.
# (systemctl restart kubelet does NOT restart running static pod containers, and
#  kubectl delete pod on a mirror pod does not restart the container either.)
mkdir -p /root/manifests-tmp
mv /etc/kubernetes/manifests/*.yaml /root/manifests-tmp/
sleep 20; crictl ps | grep -E 'kube-apiserver|etcd|kube-scheduler|kube-controller' || echo "all stopped"
mv /root/manifests-tmp/*.yaml /etc/kubernetes/manifests/
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
# admin.conf was renewed too - refresh your kubeconfig
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl get nodes
echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -dates
# The CA certificates (10 years) are not renewed by "renew all". kubelet client certs rotate by themselves.
