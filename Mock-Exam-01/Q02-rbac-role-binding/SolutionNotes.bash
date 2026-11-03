kubectl create role staging-reader -n staging --verb=list --resource=pods,deployments
kubectl create rolebinding staging-reader-dev-user -n staging --role=staging-reader --user=dev-user
kubectl auth can-i list pods --as=dev-user -n staging              # yes
kubectl auth can-i list deployments --as=dev-user -n staging       # yes
kubectl auth can-i list pods --as=dev-user -n default              # no
# --resource=deployments resolves to the apps API group, so the rule is correct for Deployments.
