kubectl -n project-hamster create sa processor
kubectl -n project-hamster create role processor --verb=create --resource=secret --resource=configmap
kubectl -n project-hamster create rolebinding processor --role processor --serviceaccount project-hamster:processor
A="--as system:serviceaccount:project-hamster:processor"
kubectl -n project-hamster auth can-i create secret $A      # yes
kubectl -n project-hamster auth can-i create configmap $A   # yes
kubectl -n project-hamster auth can-i create pod $A         # no
kubectl -n project-hamster auth can-i get configmap $A      # no
# Valid combos: Role+RoleBinding, ClusterRole+ClusterRoleBinding, ClusterRole+RoleBinding.
# Role+ClusterRoleBinding is not possible.
