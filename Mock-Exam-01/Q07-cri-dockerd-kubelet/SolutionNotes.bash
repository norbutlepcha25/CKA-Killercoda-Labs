ssh node01
systemctl status cri-docker.socket cri-docker.service --no-pager
ls -la /run/cri-dockerd.sock
# kubeadm keeps the runtime flag in /var/lib/kubelet/kubeadm-flags.env
# (/etc/kubernetes/kubelet.conf is only the kubelet's kubeconfig - not the place for this)
cat /var/lib/kubelet/kubeadm-flags.env
systemctl stop kubelet
crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmp -fa   # stop the old containerd pods
sed -i 's#--container-runtime-endpoint=[^ "]*#--container-runtime-endpoint=unix:///run/cri-dockerd.sock#' /var/lib/kubelet/kubeadm-flags.env
cat /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload && systemctl restart kubelet
exit
kubectl get nodes -o wide                 # node01 Ready, CONTAINER-RUNTIME docker://...
kubectl run rt-test --image=busybox:1.37 --overrides='{"spec":{"nodeName":"node01"}}' -- sleep 300
kubectl get pod rt-test -o wide           # Running
kubectl delete pod rt-test --force
# If the endpoint is not in kubeadm-flags.env, set containerRuntimeEndpoint in /var/lib/kubelet/config.yaml.
