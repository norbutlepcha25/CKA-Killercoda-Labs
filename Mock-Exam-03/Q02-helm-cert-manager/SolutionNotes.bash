kubectl create ns cert-manager
helm search repo jetstack
helm -n cert-manager install cert-manager jetstack/cert-manager --set crds.enabled=true
kubectl -n cert-manager rollout status deploy/cert-manager-webhook   # wait for the webhook before step 4
kubectl get crd | grep cert-manager
kubectl explain clusterissuer.spec.selfSigned                       # shows crlDistributionPoints <[]string>
cat > /root/mock3/2/cluster-issuer.yaml <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: course-issuer
spec:
  selfSigned:
    crlDistributionPoints:
    - http://example.com/crl
YAML
kubectl apply -f /root/mock3/2/cluster-issuer.yaml
kubectl get clusterissuer                                            # READY True
