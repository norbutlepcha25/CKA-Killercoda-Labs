kubectl get deploy,svc,cm -n exercise-30
kubectl get cm tls-config -n exercise-30 -o yaml | grep ssl_protocols     # TLSv1.3 only
kubectl edit cm tls-config -n exercise-30        # ssl_protocols TLSv1.2 TLSv1.3;
# or in one line:
kubectl get cm tls-config -n exercise-30 -o yaml | sed 's/ssl_protocols TLSv1.3;/ssl_protocols TLSv1.2 TLSv1.3;/' | kubectl replace -f -
kubectl rollout restart deploy tls-web -n exercise-30      # subPath mounts never auto-update
kubectl rollout status deploy tls-web -n exercise-30
IP=$(kubectl get svc tls-web -n exercise-30 -o jsonpath='{.spec.clusterIP}')
curl -sk --tlsv1.2 --tls-max 1.2 https://$IP          # Hello TLS
echo | openssl s_client -connect $IP:443 -tls1_2 2>/dev/null | grep Protocol
curl -sk --tlsv1.3 https://$IP                        # Hello TLS
