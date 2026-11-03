kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
kubectl wait --for=condition=Available deploy --all -n argocd --timeout=600s
kubectl get pods -n argocd
cat <<'EOF' > /root/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
kubectl apply -f /root/argocd-app.yaml
kubectl get application -n argocd -w          # SYNC STATUS Synced, HEALTH Healthy
kubectl get deploy,svc guestbook-ui
# UI (optional)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d; echo
kubectl port-forward -n argocd svc/argocd-server 8080:443 --address 0.0.0.0
# Exam variant (other labs): helm template ... --set crds.install=false when the CRDs are pre-installed
