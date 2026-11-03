kubectl label ns restricted \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=baseline --overwrite
kubectl get ns restricted --show-labels
kubectl run priv-pod -n restricted --image=nginx:1.27 --privileged 2> /root/mock1/q14-denied.txt
cat /root/mock1/q14-denied.txt
#   Error from server (Forbidden): pods "priv-pod" is forbidden: violates PodSecurity "restricted:latest":
#   privileged (container "priv-pod" must not set securityContext.privileged=true), allowPrivilegeEscalation != false, ...
# enforce rejects; audit only writes an annotation to the audit log; warn prints a warning to the client.
# restricted requires e.g. runAsNonRoot, allowPrivilegeEscalation=false, drop ALL capabilities and a
# seccompProfile - it does NOT require a read-only root filesystem. (PodSecurityPolicy was removed in 1.25.)
