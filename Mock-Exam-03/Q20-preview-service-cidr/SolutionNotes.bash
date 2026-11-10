kubectl run check-ip --image=httpd:2-alpine
kubectl expose pod check-ip --name check-ip-service --port 80
kubectl get svc check-ip-service                       # 10.x IP
vim /etc/kubernetes/manifests/kube-apiserver.yaml      # --service-cluster-ip-range=11.96.0.0/12
watch crictl ps                                        # wait for the new kube-apiserver
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --service-cluster-ip-range=11.96.0.0/12
# Since K8s 1.33 the allocator uses ServiceCIDR objects - add one for the new range:
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: ServiceCIDR
metadata:
  name: svc-cidr-new
spec:
  cidrs:
  - 11.96.0.0/12
YAML
kubectl delete servicecidr kubernetes --wait=false     # stays Terminating while Services still use it
kubectl expose pod check-ip --name check-ip-service2 --port 80
kubectl get svc                                        # check-ip-service2 has an 11.x IP
