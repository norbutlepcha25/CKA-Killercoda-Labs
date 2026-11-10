kubectl top -h
kubectl top pod -h | grep -A1 containers
echo 'kubectl top node' > /root/mock3/7/node.sh
echo 'kubectl top pod --containers=true' > /root/mock3/7/pod.sh
bash /root/mock3/7/node.sh; bash /root/mock3/7/pod.sh
