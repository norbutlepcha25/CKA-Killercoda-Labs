# Pods without any requests/limits get QoS class BestEffort and are evicted first.
kubectl -n project-c13 get pod -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
kubectl -n project-c13 get pod -o jsonpath='{range .items[*]}{.metadata.name} {.spec.containers[*].resources}{"\n"}{end}'
kubectl -n project-c13 get pod -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' \
  > /root/mock3/4/pods-terminated-first.txt
# Note: c13-3cc-data only has a memory limit -> requests default to the limit, but cpu is unset -> Burstable,
# not BestEffort. c13-2x3-web has requests == limits -> Guaranteed.
