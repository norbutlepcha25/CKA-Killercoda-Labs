kubectl get nodes
kubectl cordon node01
kubectl get nodes                                        # node01 SchedulingDisabled
kubectl create deployment drain-test --image=nginx:1.27 --replicas=3
kubectl get pods -o wide
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
kubectl get pods -A --field-selector spec.nodeName=node01   # only DaemonSet pods left
kubectl uncordon node01
kubectl scale deployment drain-test --replicas=6
kubectl get pods -o wide                                 # some pods on node01 again
