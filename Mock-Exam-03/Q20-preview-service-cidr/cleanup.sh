#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
kubectl delete svc check-ip-service check-ip-service2 -n default --ignore-not-found >/dev/null 2>&1
kubectl delete pod check-ip -n default --ignore-not-found --force --grace-period=0 >/dev/null 2>&1
if grep -q -- '--service-cluster-ip-range=11.96.0.0/12' $APISERVER_MANIFEST && [ -f $APISERVER_PRISTINE ]; then
  cp $APISERVER_PRISTINE $APISERVER_MANIFEST; echo "Restoring kube-apiserver manifest ..."; wait_apiserver 240
fi
KCM=/etc/kubernetes/manifests/kube-controller-manager.yaml; KCMP=/root/.cka-lab/mock3-kcm.pristine.yaml
[ -f $KCMP ] && ! cmp -s $KCMP $KCM && cp $KCMP $KCM
for sc in $(kubectl get servicecidr -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  [ "$sc" = kubernetes ] || kubectl delete servicecidr "$sc" --wait=false >/dev/null 2>&1
done
# a deleted default ServiceCIDR stays Terminating forever while kubernetes.default uses it:
# drop the finalizer so the API server recreates it from its flags
if [ -n "$(jp '{.metadata.deletionTimestamp}' servicecidr kubernetes)" ]; then
  kubectl patch servicecidr kubernetes --type=merge -p '{"metadata":{"finalizers":null}}' >/dev/null 2>&1
  for i in $(seq 1 30); do kubectl get servicecidr kubernetes >/dev/null 2>&1 && [ -z "$(jp '{.metadata.deletionTimestamp}' servicecidr kubernetes)" ] && break; sleep 3; done
fi
rm -rf /root/mock3/20
true
