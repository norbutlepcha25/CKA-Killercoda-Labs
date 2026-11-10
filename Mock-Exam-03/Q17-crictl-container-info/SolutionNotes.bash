kubectl -n project-puma run tigers-reunite --image=httpd:2-alpine --labels "pod=container,container=pod"
kubectl -n project-puma get pod tigers-reunite -o wide          # NODE, e.g. node01
ssh node01
crictl ps | grep tigers-reunite                                 # container ID
crictl inspect <ID> | grep runtimeType                          # io.containerd.runc.v2
exit
echo "<ID> io.containerd.runc.v2" > /root/mock3/17/pod-container.txt
ssh node01 "crictl logs <ID>" > /root/mock3/17/pod-container.log 2>&1   # httpd logs to stderr
