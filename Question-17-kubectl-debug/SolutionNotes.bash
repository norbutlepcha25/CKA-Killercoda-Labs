# Part A
kubectl create ns exercise-17
kubectl run broken-app -n exercise-17 --image=nginx:1.27
kubectl wait --for=condition=Ready pod/broken-app -n exercise-17
kubectl debug broken-app -n exercise-17 -it --image=busybox:1.36 --target=broken-app
  ps aux                       # nginx master + workers
  ls /proc/1/root/etc/nginx/   # target container filesystem
  wget -qO- localhost:80       # network namespace is shared
  exit

# Part B
kubectl debug node/node01 -it --image=busybox:1.36
  chroot /host
  systemctl status kubelet
  journalctl -u kubelet --no-pager | tail -20
  crictl ps
  exit   # leave chroot
  exit   # leave debug pod
kubectl get pods | grep node-debugger
