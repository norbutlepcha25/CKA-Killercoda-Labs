kubectl -n project-h800 get pod | grep o3db
kubectl -n project-h800 get deploy,ds,sts | grep o3db       # it is a StatefulSet
kubectl -n project-h800 scale sts o3db --replicas 1
kubectl -n project-h800 get sts o3db                       # READY 1/1
