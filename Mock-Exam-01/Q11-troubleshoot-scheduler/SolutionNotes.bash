kubectl get pods -n kube-system | grep scheduler           # CrashLoopBackOff (or missing)
kubectl get pod sched-test                                 # Pending, no node assigned
crictl ps -a --name kube-scheduler                         # Exited
crictl logs $(crictl ps -a --name kube-scheduler -q | head -1) 2>&1 | tail -5
#   ... stat /etc/kubernetes/scheduler.config: no such file or directory
journalctl -u kubelet --no-pager | grep -i scheduler | tail -5
ls /etc/kubernetes/*.conf                                  # the real file is scheduler.conf
grep kubeconfig /etc/kubernetes/manifests/kube-scheduler.yaml
sed -i 's#/etc/kubernetes/scheduler.config#/etc/kubernetes/scheduler.conf#g' /etc/kubernetes/manifests/kube-scheduler.yaml
sleep 30; crictl ps --name kube-scheduler                  # Running
kubectl get pod sched-test -o wide                         # scheduled, Running
echo "kube-scheduler manifest pointed --kubeconfig/--authentication-kubeconfig/--authorization-kubeconfig at /etc/kubernetes/scheduler.config (does not exist); fixed to scheduler.conf" > /root/mock1/q11-cause.txt
# Restarting kubelet is not needed: it notices manifest changes by itself.
