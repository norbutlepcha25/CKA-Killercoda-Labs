kubectl rollout history deployment/payment-service -n payments
#   1  v1.0 initial release (nginx:1.25)
#   2  v1.1 performance fixes (nginx:1.26)
#   3  v1.2 stable (nginx:1.27)
#   4  v1.3 hotfix
kubectl rollout history deployment/payment-service -n payments --revision=4     # image nginx:1.27-payments-hotfix
kubectl get pods -n payments                                                     # ErrImagePull / ImagePullBackOff
echo 4 > /root/mock2/q02-bad-revision.txt
kubectl rollout undo deployment/payment-service -n payments                      # back to the previous revision (3)
#   or: kubectl rollout undo deployment/payment-service -n payments --to-revision=3
kubectl rollout status deployment/payment-service -n payments
kubectl get deploy payment-service -n payments -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl rollout history deployment/payment-service -n payments                   # revision 3 is now revision 5
