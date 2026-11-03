echo web-ui.frontend.svc.cluster.local > /root/mock2/q01-fqdn.txt     # <service>.<namespace>.svc.cluster.local
kubectl run dns-test -n backend --image=busybox:1.37 -- sleep 3600
kubectl wait --for=condition=Ready pod/dns-test -n backend
kubectl exec dns-test -n backend -- nslookup web-ui.frontend.svc.cluster.local
kubectl get svc web-ui -n frontend -o jsonpath='{.spec.clusterIP}' > /root/mock2/q01-ip.txt
kubectl exec dns-test -n backend -- wget -qO- http://web-ui.frontend:3000           # hello from web-ui
# From another namespace the short name "web-ui" does NOT resolve - you need at least web-ui.frontend.
# DNS returns the ClusterIP of a normal Service (pod IPs only for headless Services).
