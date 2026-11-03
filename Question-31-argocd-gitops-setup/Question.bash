# Question 31 - Argo CD Setup (GitOps Deployment)  (Cluster Architecture | Hard | 25 min)
#
# Tasks
# 1. Install Argo CD v3.1.9 in the cluster:
#    - Create the argocd namespace
#    - Apply the official manifest (it includes the CRDs - install them once, with server-side apply):
#      https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
# 2. Write an Application manifest and save it to /root/argocd-app.yaml:
#    - name my-app, namespace argocd, project default
#    - source: https://github.com/argoproj/argocd-example-apps.git, revision HEAD, path guestbook
#    - destination: https://kubernetes.default.svc, namespace default
#    - automated sync (prune + selfHeal)
# 3. Verify the Argo CD server is Running
# 4. Apply the Application manifest
# 5. Verify the application syncs (status Synced) and the guestbook-ui Deployment appears in default
# 6. Optional: port-forward to the Argo CD UI and log in as admin
