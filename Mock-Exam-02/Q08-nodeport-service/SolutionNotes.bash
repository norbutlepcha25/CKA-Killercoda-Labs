cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: legacy-app
  namespace: legacy
spec:
  type: NodePort
  selector:
    app: legacy
  ports:
  - protocol: TCP
    port: 8080          # ClusterIP port inside the cluster
    targetPort: 3000    # container port
    nodePort: 30080     # opened on every node (30000-32767)
EOF
kubectl get svc legacy-app -n legacy                  # 8080:30080/TCP
kubectl get endpointslices -n legacy
IP=$(kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl http://$IP:30080                                 # legacy-app OK
# kubectl expose deploy legacy-app -n legacy --type=NodePort --port=8080 --target-port=3000
# also works, but picks a random nodePort - patch it to 30080 afterwards.
