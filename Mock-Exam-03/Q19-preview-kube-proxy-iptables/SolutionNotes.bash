kubectl -n project-lynx run p2-pod --image=nginx:1-alpine
kubectl -n project-lynx expose pod p2-pod --name p2-service --port 3000 --target-port 80
kubectl -n project-lynx get pod,svc,endpointslice
crictl ps | grep kube-proxy; crictl logs <id> 2>&1 | grep -i proxier   # "Using iptables proxy"
iptables-save | grep p2-service
iptables-save | grep p2-service > /root/mock3/19/iptables.txt
kubectl -n project-lynx delete svc p2-service
iptables-save | grep p2-service                                        # nothing
