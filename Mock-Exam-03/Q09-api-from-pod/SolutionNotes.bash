kubectl -n project-swan run api-contact --image=nginx:1-alpine --dry-run=client -o yaml \
  --overrides='{"spec":{"serviceAccountName":"secret-reader"}}' | kubectl apply -f -
kubectl -n project-swan exec -it api-contact -- sh
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  curl --cacert $CACERT https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer $TOKEN" > /tmp/result.json
  # (curl -k ... works too; without the token you are system:anonymous and get 403)
  exit
kubectl -n project-swan exec api-contact -- cat /tmp/result.json > /root/mock3/9/result.json
kubectl auth can-i list secrets --as system:serviceaccount:project-swan:secret-reader   # yes
