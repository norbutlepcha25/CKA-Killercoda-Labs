kubectl run root-app -n restricted --image=nginx:1.27      # forbidden: violates PodSecurity "restricted:latest"
kubectl create ns legacy-root
kubectl label ns legacy-root pod-security.kubernetes.io/enforce=baseline
kubectl run root-app -n legacy-root --image=nginx:1.27
kubectl exec root-app -n legacy-root -- id                 # uid=0(root)
kubectl run p -n legacy-root --image=nginx:1.27 --privileged --dry-run=server   # forbidden (baseline)
# A label such as pod-security.kubernetes.io/exempt=true on a pod does nothing.
# Real exemptions are configured in the API server's AdmissionConfiguration
# (--admission-control-config-file), PodSecurity plugin -> exemptions: usernames / runtimeClasses / namespaces.
# They apply cluster-wide to everything that matches, which is why a dedicated namespace is usually better.
