kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep cluster-cidr
# or: kubectl get cm kubeadm-config -n kube-system -o yaml | grep -i podSubnet
CIDR=<the value above, e.g. 192.168.0.0/16>
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
kubectl wait --for=condition=Available deploy/tigera-operator -n tigera-operator --timeout=300s
cat <<EOF | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: $CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
watch kubectl get tigerastatus                # calico Available True
kubectl get pods -n calico-system
kubectl get nodes                             # Ready
kubectl -n kube-system rollout restart deploy coredns
# test cross-node pod traffic
kubectl run a --image=busybox:1.36 --overrides='{"spec":{"nodeName":"controlplane","tolerations":[{"operator":"Exists"}]}}' -- sleep 3600
kubectl run b --image=busybox:1.36 --overrides='{"spec":{"nodeName":"node01"}}' -- sleep 3600
kubectl exec a -- ping -c2 $(kubectl get pod b -o jsonpath='{.status.podIP}')
# NetworkPolicy test: deny all ingress to b, ping again -> fails
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-b
spec:
  podSelector:
    matchLabels:
      run: b
  policyTypes: [Ingress]
EOF
kubectl exec a -- ping -c2 -W2 $(kubectl get pod b -o jsonpath='{.status.podIP}')   # fails
kubectl delete netpol deny-b; kubectl delete pod a b --now
