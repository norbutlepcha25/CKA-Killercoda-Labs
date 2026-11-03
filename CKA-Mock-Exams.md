# CKA Killercoda Mock Exams

Two timed mock exams, 15 questions each, 120 minutes, passing score 66% (10/15).
Each question has its own setup, an automatic checker and a hidden solution. `./mock.sh <exam> score` checks all 15 at once.

## Setup (once per Killercoda session)

```bash
git clone https://github.com/norbutlepcha25/CKA-Killercoda-Labs.git
cd CKA-Killercoda-Labs
chmod +x lab.sh mock.sh lib/*.sh Question-*/*.sh Mock-Exam-*/*/*.sh
./mock.sh list
```

## Run a full exam

```bash
./mock.sh 1 start          # sets up all questions (except Q11), starts a 120-minute clock
./mock.sh 1 time           # time left
./mock.sh 1 3 question     # show question 3 again
./mock.sh 1 score          # check everything, prints your score
./mock.sh 1 cleanup        # remove everything the exam created
```

Use a fresh Killercoda session for each exam. Answer files go in `/root/mock1/` or `/root/mock2/`.

---

# Mock Exam 01

## Exam 1 · Q1 – Pod Deployment Troubleshooting  (Troubleshooting | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 1
```

**Question**
```text
Pod app-frontend in namespace production is in CrashLoopBackOff. Its container expects a
config file at /etc/app/config.yaml, which the image does not contain.
The pod manifest is at /root/mock1/app-frontend.yaml.

Tasks
1. Create a ConfigMap named app-config in namespace production with a key config.yaml
   whose content is:   database_host: postgres.production.svc.cluster.local
2. Mount the ConfigMap so the file appears at /etc/app/config.yaml in the container
   (update the manifest and recreate the pod)
3. Verify the pod starts and stays Running
```

**Validate**
```bash
./mock.sh 1 1 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl -n production logs app-frontend                 # ERROR: /etc/app/config.yaml not found
kubectl create configmap app-config -n production \
  --from-literal=config.yaml='database_host: postgres.production.svc.cluster.local'

# Add the volume + mount to the manifest. The finished file:
cat <<'EOF' > /root/mock1/app-frontend.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
  labels:
    app: app-frontend
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "if [ ! -f /etc/app/config.yaml ]; then echo 'ERROR: /etc/app/config.yaml not found'; exit 1; fi; echo 'config loaded:'; cat /etc/app/config.yaml; exec sleep 3600"]
    volumeMounts:
    - name: config
      mountPath: /etc/app            # the key config.yaml becomes /etc/app/config.yaml
  volumes:
  - name: config
    configMap:
      name: app-config
      items:
      - key: config.yaml
        path: config.yaml
EOF
# A running pod can't get new volumes - recreate it
kubectl replace --force -f /root/mock1/app-frontend.yaml
kubectl get pod app-frontend -n production
kubectl exec app-frontend -n production -- cat /etc/app/config.yaml
# Alternative: mountPath /etc/app/config.yaml + subPath config.yaml mounts only that one file
# (but subPath mounts do not receive ConfigMap updates).
```

</details>

## Exam 1 · Q2 – RBAC  (Cluster Architecture | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 2
```

**Question**
```text
The user dev-user must be able to list Pods and Deployments in namespace staging,
and nothing in other namespaces.

Tasks
1. Create a Role named staging-reader in namespace staging that allows listing Pods and Deployments
2. Create a RoleBinding named staging-reader-dev-user that grants this Role to the user dev-user
3. Verify with kubectl auth can-i (also check that dev-user can't list pods in namespace default)
```

**Validate**
```bash
./mock.sh 1 2 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create role staging-reader -n staging --verb=list --resource=pods,deployments
kubectl create rolebinding staging-reader-dev-user -n staging --role=staging-reader --user=dev-user
kubectl auth can-i list pods --as=dev-user -n staging              # yes
kubectl auth can-i list deployments --as=dev-user -n staging       # yes
kubectl auth can-i list pods --as=dev-user -n default              # no
# --resource=deployments resolves to the apps API group, so the rule is correct for Deployments.
```

</details>

## Exam 1 · Q3 – Node Maintenance  (Cluster Architecture | 6 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 3
```

**Question**
```text
Node node01 needs maintenance. In namespace maintenance it runs:
  - Deployment web (3 replicas)
  - a standalone pod database that keeps its data on node-local storage (emptyDir)

Tasks
1. Make sure no new pods are scheduled to node01
2. Move the web pods off node01
3. The database pod must NOT be evicted or deleted: it must still be the same pod, Running on node01
4. Leave node01 in that state (the maintenance itself has not started yet)

Note: while node01 is unschedulable, new pods from other questions only go to the control plane.
```

**Validate**
```bash
./mock.sh 1 3 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl get pods -n maintenance -o wide
kubectl cordon node01
# A plain drain refuses: database is not managed by a controller and uses emptyDir.
#   kubectl drain node01 --ignore-daemonsets
#   error: cannot delete Pods that declare no controller (use --force to override): maintenance/database
# --force --delete-emptydir-data would DELETE the database pod and its data - not allowed here.
# Move only the web pods: with node01 cordoned, the Deployment recreates them elsewhere.
kubectl delete pod -n maintenance -l app=web --field-selector spec.nodeName=node01
# Alternative: kubectl drain node01 --ignore-daemonsets --pod-selector=app=web
#   but --pod-selector matches pods in ALL namespaces - any other unmanaged app=web pod makes it fail.
kubectl get pods -n maintenance -o wide      # database still on node01, web pods elsewhere (or Pending)
kubectl get node node01                      # Ready,SchedulingDisabled
# After the maintenance:  kubectl uncordon node01
```

</details>

## Exam 1 · Q4 – Persistent Volume Configuration  (Storage | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 4
```

**Question**
```text
Deployment db-app in namespace databases needs persistent storage that several pods can use
at the same time. This cluster has no dynamic SSD provisioner, so you provision it statically.

Tasks
1. Create StorageClass fast-ssd with provisioner kubernetes.io/no-provisioner
2. Create PersistentVolume db-pv: 5Gi, access mode ReadWriteMany, storageClassName fast-ssd,
   hostPath /mnt/fast-ssd
3. Create PersistentVolumeClaim db-storage in namespace databases: 5Gi, ReadWriteMany,
   storageClassName fast-ssd - it must be Bound to db-pv
4. Mount the claim at /data in the db-app containers and make sure the rollout completes
```

**Validate**
```bash
./mock.sh 1 4 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/no-provisioner
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 5Gi
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  hostPath:
    path: /mnt/fast-ssd
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-storage
  namespace: databases
spec:
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 5Gi
EOF
kubectl get pvc db-storage -n databases            # Bound to db-pv
# (kubectl has no "set volume" - that is an OpenShift oc command). Patch or kubectl edit:
kubectl patch deployment db-app -n databases --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"data","persistentVolumeClaim":{"claimName":"db-storage"}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"data","mountPath":"/data"}]}]'
kubectl rollout status deployment/db-app -n databases
kubectl exec deploy/db-app -n databases -- df -h /data
# Note: hostPath is node-local. It satisfies ReadWriteMany for this lab, but real shared storage
# (NFS, CephFS, EFS, Filestore ...) is what makes RWX useful across nodes.
```

</details>

## Exam 1 · Q5 – Network Policies  (Services & Networking | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 5
```

**Question**
```text
In namespace shop all pods can currently talk to each other. Pods:
  frontend (tier=frontend, port 80)   backend (tier=backend, port 3000)
  database (tier=database, port 5432) outsider (no tier label - use it for testing)

Create NetworkPolicies in namespace shop so that:
1. Pods with tier=frontend accept incoming traffic on TCP port 80 only (from anywhere)
2. Pods with tier=backend accept incoming traffic only from tier=frontend pods, on TCP port 3000
3. Pods with tier=database accept incoming traffic only from tier=backend pods, on TCP port 5432
Outgoing traffic must not be restricted.
```

**Validate**
```bash
./mock.sh 1 5 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes: ["Ingress"]
  ingress:
  - ports:                       # no "from" = any source
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
EOF
B=$(kubectl get pod backend -n shop -o jsonpath='{.status.podIP}')
kubectl exec frontend -n shop -- curl -s -m3 -o /dev/null -w '%{http_code}\n' http://$B:3000   # 200
kubectl exec outsider -n shop -- curl -s -m3 http://$B:3000 || echo blocked                     # blocked
# policyTypes only lists Ingress, so egress stays open (DNS etc. keep working).
# Note: "protocol" belongs inside each "ports" entry - an ingress rule has only "from" and "ports".
```

</details>

## Exam 1 · Q6 – Helm Chart Deployment  (Cluster Architecture | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 6
```

**Question**
```text
A local Helm chart named monitoring is in /root/helm-charts/monitoring.

Tasks
1. Install the chart as release monitoring-stack in namespace monitoring (create the namespace
   if it doesn't exist), overriding these chart values:
     replica_count = 3
     storage_size  = 50Gi
     persistence   = true   (a boolean)
2. Verify the release is deployed and the Deployment has 3 ready replicas
```

**Validate**
```bash
./mock.sh 1 6 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat /root/helm-charts/monitoring/values.yaml          # see the value names
helm install monitoring-stack /root/helm-charts/monitoring \
  -n monitoring --create-namespace \
  --set replica_count=3 \
  --set storage_size=50Gi \
  --set persistence=true
helm list -n monitoring
helm get values monitoring-stack -n monitoring
kubectl get deploy,pvc -n monitoring
# Same thing with a values file:  helm install ... -f my-values.yaml
# --set turns "true" into a boolean; use --set-string if you ever need the string "true".
```

</details>

## Exam 1 · Q7 – Container Runtime Configuration  (Cluster Architecture | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 7
```

**Question**
```text
The worker node node01 must use cri-dockerd instead of containerd.
Docker and cri-dockerd are already installed and running on node01
(cri-docker.socket / cri-docker.service, socket unix:///run/cri-dockerd.sock).

Tasks
1. Configure the kubelet on node01 to use the cri-dockerd socket and restart it
2. Verify node01 is Ready and reports a docker:// container runtime
3. Verify that a pod scheduled to node01 starts

This changes node01 for the rest of the session. ./mock.sh 1 7 cleanup switches it back.
```

**Validate**
```bash
./mock.sh 1 7 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Exam 1 · Q8 – API Server Audit Logs  (Troubleshooting | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 8
```

**Question**
```text
Somebody keeps reading ConfigMaps in namespace default. Use audit logging to find out who.

Tasks
1. Enable audit logging on the kube-apiserver (control plane node):
   - audit policy file /etc/kubernetes/audit/policy.yaml that logs ConfigMap requests at level
     Metadata (or higher). Everything else may be logged at level None.
   - audit log file /var/log/kubernetes/audit/audit.log
   - --audit-log-maxbackup=2 and --audit-log-maxsize=10
2. Wait for new requests. Find the ServiceAccount that keeps listing ConfigMaps in namespace
   default and write its audit username to /root/mock1/q08-user.txt
   (kubelets also watch ConfigMaps - ignore system:node:* users)
3. Write the HTTP response code those requests get to /root/mock1/q08-code.txt
4. Write the requestReceivedTimestamp of one of those requests to /root/mock1/q08-time.txt

Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
```

**Validate**
```bash
./mock.sh 1 8 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
mkdir -p /etc/kubernetes/audit /var/log/kubernetes/audit
cat <<'EOF' > /etc/kubernetes/audit/policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"]
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["configmaps"]
- level: None
EOF
# Edit /etc/kubernetes/manifests/kube-apiserver.yaml (keep any backup OUTSIDE the manifests dir):
#   command:
#   - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxbackup=2
#   - --audit-log-maxsize=10
#   volumeMounts:
#   - name: audit-policy
#     mountPath: /etc/kubernetes/audit
#     readOnly: true
#   - name: audit-log
#     mountPath: /var/log/kubernetes/audit
#   volumes:
#   - name: audit-policy
#     hostPath: {path: /etc/kubernetes/audit, type: DirectoryOrCreate}
#   - name: audit-log
#     hostPath: {path: /var/log/kubernetes/audit, type: DirectoryOrCreate}
# The same edit with sed:
M=/etc/kubernetes/manifests/kube-apiserver.yaml
cp $M /root/kube-apiserver.yaml.bak
sed -i '/- kube-apiserver$/a\    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml\n    - --audit-log-path=/var/log/kubernetes/audit/audit.log\n    - --audit-log-maxbackup=2\n    - --audit-log-maxsize=10' $M
sed -i '0,/^    volumeMounts:$/s##    volumeMounts:\n    - mountPath: /etc/kubernetes/audit\n      name: audit-policy\n      readOnly: true\n    - mountPath: /var/log/kubernetes/audit\n      name: audit-log#' $M
sed -i '0,/^  volumes:$/s##  volumes:\n  - hostPath:\n      path: /etc/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-policy\n  - hostPath:\n      path: /var/log/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-log#' $M
# wait until the API server is back (30-90s)
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
until grep -q 'serviceaccount:ops' /var/log/kubernetes/audit/audit.log 2>/dev/null; do sleep 5; done
# Each line of the audit log is one JSON event (JSON lines, not one big array):
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | tail -3
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | grep -v system:node: \
  | jq -r '[.user.username, .verb, .responseStatus.code, .requestReceivedTimestamp] | @tsv' | sort | uniq -c | tail
L=$(grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep 'system:serviceaccount:ops:config-sync' | tail -1)
echo "$L" | jq -r .user.username > /root/mock1/q08-user.txt          # system:serviceaccount:ops:config-sync
echo "$L" | jq -r .responseStatus.code > /root/mock1/q08-code.txt     # 403 - it has no RBAC permission
echo "$L" | jq -r .requestReceivedTimestamp > /root/mock1/q08-time.txt
```

</details>

## Exam 1 · Q9 – HPA and Application Scaling  (Workloads & Scheduling | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 9
```

**Question**
```text
Deployment web-app in namespace production runs 2 replicas. metrics-server is installed.

Tasks
1. Create a HorizontalPodAutoscaler named web-app for Deployment web-app that keeps the average
   CPU utilization at 70%, with at least 2 and at most 10 replicas
2. Verify the HPA reads CPU metrics (TARGETS shows a percentage, not <unknown>)
```

**Validate**
```bash
./mock.sh 1 9 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl autoscale deployment web-app -n production --min=2 --max=10 --cpu-percent=70
# (kubectl 1.35 may print a deprecation note for --cpu-percent; the result is the same autoscaling/v2 object)
kubectl get hpa web-app -n production          # TARGETS cpu: 0%/70% after ~30-60s
kubectl describe hpa web-app -n production
# YAML version:
# apiVersion: autoscaling/v2
# kind: HorizontalPodAutoscaler
# metadata: {name: web-app, namespace: production}
# spec:
#   scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web-app}
#   minReplicas: 2
#   maxReplicas: 10
#   metrics:
#   - type: Resource
#     resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
# Utilization is measured against the pods' CPU *requests* - without requests the HPA shows <unknown>.
```

</details>

## Exam 1 · Q10 – Ingress with TLS  (Services & Networking | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 10
```

**Question**
```text
Service api (namespace default, port 80) must be published through ingress-nginx
(IngressClass nginx, already installed). The TLS secret api-tls-cert already exists in default.

Tasks
1. Create Ingress api-ingress for host api.example.com:
   - TLS using secret api-tls-cert
   - path /api (pathType Prefix) -> service api port 80
2. Also route /health on host api.example.com to service api port 80. Load balancer health
   checks call it over plain HTTP, so HTTP requests to /health must be answered directly
   (not redirected to HTTPS), while HTTP requests to /api are still redirected.
   Hint: ingress-nginx annotations apply to a whole Ingress object.
3. Test with curl against the ingress-nginx NodePorts (use --resolve or a Host header)
```

**Validate**
```bash
./mock.sh 1 10 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts: ["api.example.com"]
    secretName: api-tls-cert
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-health
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"     # only for the paths of THIS Ingress
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /health
        pathType: Exact
        backend:
          service:
            name: api
            port:
              number: 80
EOF
IP=$(kubectl get node controlplane -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
HP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
SP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
curl -sk --resolve api.example.com:$SP:$IP https://api.example.com:$SP/api/                          # api says hello
curl -s -o /dev/null -w '%{http_code}\n' --resolve api.example.com:$HP:$IP http://api.example.com:$HP/api/    # 308
curl -s --resolve api.example.com:$HP:$IP http://api.example.com:$HP/health                          # api says hello
# Why two Ingresses: once a host has TLS, ingress-nginx redirects HTTP -> HTTPS (308).
# The ssl-redirect annotation is per Ingress, so /health lives in its own Ingress with redirect off.
```

</details>

## Exam 1 · Q11 – Cluster Troubleshooting  (Troubleshooting | 12 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 11
```

**Question**
```text
The kube-scheduler has stopped running. Pod sched-test in namespace default stays Pending.

Tasks
1. Check the status of the control plane components
2. Find out why the kube-scheduler is not running (static pod - kubelet / container logs)
3. Fix it so the scheduler runs again and sched-test gets scheduled
4. Document the root cause in one line in /root/mock1/q11-cause.txt

Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
(./mock.sh 1 start does not break the scheduler - run ./mock.sh 1 11 when you reach this question.)
```

**Validate**
```bash
./mock.sh 1 11 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Exam 1 · Q12 – StatefulSet with Persistent Storage  (Workloads & Storage | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 12
```

**Question**
```text
Tasks (namespace default)
1. Create a headless Service database-cluster exposing port 5432, selecting app=database-cluster
2. Create a StatefulSet database-cluster:
   - 3 replicas, serviceName database-cluster, pod label app=database-cluster
   - container postgres, image postgres:17-alpine, port 5432, env POSTGRES_PASSWORD=mockexam
   - a volumeClaimTemplate named data: 10Gi, ReadWriteOnce, storageClassName local-path,
     mounted at /var/lib/postgresql/data
3. Verify all 3 pods are Ready, each has its own Bound PVC, and that the stable DNS name
   database-cluster-0.database-cluster resolves from another pod
```

**Validate**
```bash
./mock.sh 1 12 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
  namespace: default
spec:
  clusterIP: None
  selector:
    app: database-cluster
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database-cluster
  namespace: default
spec:
  serviceName: database-cluster
  replicas: 3
  selector:
    matchLabels:
      app: database-cluster
  template:
    metadata:
      labels:
        app: database-cluster
    spec:
      containers:
      - name: postgres
        image: postgres:17-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: mockexam
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 10Gi
EOF
kubectl rollout status sts database-cluster
kubectl get pods -l app=database-cluster -o wide
kubectl get pvc                         # data-database-cluster-0/1/2, all Bound
kubectl exec database-cluster-1 -- nslookup database-cluster-0.database-cluster
# PVC names are <template name>-<pod name>. postgres needs POSTGRES_PASSWORD or it exits.
```

</details>

## Exam 1 · Q13 – Resource Quotas and Limits  (Workloads & Scheduling | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 13
```

**Question**
```text
Namespace test uses too many resources.

Tasks
1. Create ResourceQuota test-quota in namespace test: total CPU requests 4 cores and total
   memory requests 8Gi (you may also cap limits at the same values)
2. Create LimitRange test-limits in namespace test so every container must request at least
   100m CPU and 128Mi memory
3. Verify that a pod requesting 6 CPUs / 4Gi (limits equal) is rejected, and so is a pod
   requesting 50m CPU / 64Mi. Save the error for the 6-CPU pod to /root/mock1/q13-rejected.txt
```

**Validate**
```bash
./mock.sh 1 13 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "4"
    limits.memory: 8Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
  namespace: test
spec:
  limits:
  - type: Container
    min:
      cpu: 100m
      memory: 128Mi
EOF
kubectl describe quota test-quota -n test
kubectl describe limitrange test-limits -n test
# kubectl run has no --requests flag any more (removed in 1.24) - use --overrides or YAML:
kubectl run big -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"big","image":"nginx:1.27","resources":{"requests":{"cpu":"6","memory":"4Gi"},"limits":{"cpu":"6","memory":"4Gi"}}}]}}' 2> /root/mock1/q13-rejected.txt
cat /root/mock1/q13-rejected.txt     # forbidden: exceeded quota: test-quota, requested: ... cpu=6 ...
kubectl run tiny -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"tiny","image":"nginx:1.27","resources":{"requests":{"cpu":"50m","memory":"64Mi"},"limits":{"cpu":"50m","memory":"64Mi"}}}]}}'
#   forbidden: minimum cpu usage per Container is 100m, but request is 50m
# Note: a 2 CPU / 2Gi pod (the original wording) FITS a 4 CPU / 8Gi quota - it would be admitted.
# With limits.* in the quota, every pod must also set limits (or get them from a LimitRange default).
```

</details>

## Exam 1 · Q14 – Pod Security Standards  (Cluster Architecture | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 14
```

**Question**
```text
Namespace restricted must enforce security policies with Pod Security Admission.

Tasks
1. Enforce the restricted Pod Security Standard on namespace restricted
2. Audit at level baseline in the same namespace
3. Try to create a pod with privileged: true in restricted and verify it is denied.
   Save the error message to /root/mock1/q14-denied.txt
```

**Validate**
```bash
./mock.sh 1 14 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Exam 1 · Q15 – Multi-Container Pod with Sidecar  (Workloads & Scheduling | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 1 15
```

**Question**
```text
Tasks (namespace default)
Create pod app-with-logger with:
1. Container nginx, image nginx:1.28
2. Container logger, image busybox:1.37, that follows the nginx access log:  tail -F /logs/access.log
3. An emptyDir volume shared by both: mounted at /var/log/nginx in nginx and at /logs in logger
4. Both containers keep running without restarts, and requests to nginx show up in
   kubectl logs app-with-logger -c logger
```

**Validate**
```bash
./mock.sh 1 15 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logger
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:1.28
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  - name: logger
    image: busybox:1.37
    command: ["sh", "-c", "tail -F /logs/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /logs
  volumes:
  - name: logs
    emptyDir: {}
EOF
kubectl get pod app-with-logger
kubectl exec app-with-logger -c nginx -- curl -s localhost >/dev/null
kubectl logs app-with-logger -c logger
# The nginx image links access.log to /dev/stdout; mounting the emptyDir over /var/log/nginx
# replaces those links, so nginx writes real files the sidecar can read.
# tail -F (capital F) keeps retrying if the file doesn't exist yet - tail -f would exit and crash-loop.
# A native sidecar (initContainers + restartPolicy: Always) is fine too.
```

</details>

---

# Mock Exam 02

## Exam 2 · Q1 – Service Discovery and DNS  (Services & Networking | 6 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 1
```

**Question**
```text
Service web-ui in namespace frontend exposes port 3000. An application in namespace backend
must call it by DNS.

Tasks
1. Write the fully qualified DNS name of the service to /root/mock2/q01-fqdn.txt
2. Create pod dns-test in namespace backend (image busybox:1.37, command: sleep 3600)
3. From dns-test, resolve the service name with nslookup and write the IP it resolves to
   into /root/mock2/q01-ip.txt
4. From dns-test, fetch http://web-ui.frontend:3000 and check the answer
```

**Validate**
```bash
./mock.sh 2 1 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
echo web-ui.frontend.svc.cluster.local > /root/mock2/q01-fqdn.txt     # <service>.<namespace>.svc.cluster.local
kubectl run dns-test -n backend --image=busybox:1.37 -- sleep 3600
kubectl wait --for=condition=Ready pod/dns-test -n backend
kubectl exec dns-test -n backend -- nslookup web-ui.frontend.svc.cluster.local
kubectl get svc web-ui -n frontend -o jsonpath='{.spec.clusterIP}' > /root/mock2/q01-ip.txt
kubectl exec dns-test -n backend -- wget -qO- http://web-ui.frontend:3000           # hello from web-ui
# From another namespace the short name "web-ui" does NOT resolve - you need at least web-ui.frontend.
# DNS returns the ClusterIP of a normal Service (pod IPs only for headless Services).
```

</details>

## Exam 2 · Q2 – Deployment Rolling Update and Rollback  (Workloads | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 2
```

**Question**
```text
Deployment payment-service in namespace payments was updated to a version that does not work.

Tasks
1. Check the rollout history of payment-service
2. Write the number of the broken revision to /root/mock2/q02-bad-revision.txt
3. Roll back to the last working version (image nginx:1.27)
4. Verify the rollback completed and all 3 replicas are available
```

**Validate**
```bash
./mock.sh 2 2 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl rollout history deployment/payment-service -n payments
#   1  v1.0 initial release (nginx:1.25)
#   2  v1.1 performance fixes (nginx:1.26)
#   3  v1.2 stable (nginx:1.27)
#   4  v1.3 hotfix
kubectl rollout history deployment/payment-service -n payments --revision=4     # image nginx:1.27-payments-hotfix
kubectl get pods -n payments                                                     # ErrImagePull / ImagePullBackOff
echo 4 > /root/mock2/q02-bad-revision.txt
kubectl rollout undo deployment/payment-service -n payments                      # back to the previous revision (3)
#   or: kubectl rollout undo deployment/payment-service -n payments --to-revision=3
kubectl rollout status deployment/payment-service -n payments
kubectl get deploy payment-service -n payments -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl rollout history deployment/payment-service -n payments                   # revision 3 is now revision 5
```

</details>

## Exam 2 · Q3 – Secrets and Environment Variables  (Workloads | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 3
```

**Question**
```text
Deployment app-deploy in namespace secrets-demo (container app) needs database credentials.

Tasks
1. Create a Secret db-creds in secrets-demo with keys:
     username=dbuser   password=secret123   database=appdb
2. Expose them to the app container as the environment variables DB_USERNAME, DB_PASSWORD and
   DB_DATABASE, taken from the Secret (not as files, and not as plain values in the Deployment)
3. Verify the new pod sees the variables, without the values appearing in the pod logs
```

**Validate**
```bash
./mock.sh 2 3 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create secret generic db-creds -n secrets-demo \
  --from-literal=username=dbuser --from-literal=password=secret123 --from-literal=database=appdb
# Quick way: one secretKeyRef per key, names upper-cased with the prefix
kubectl set env deployment/app-deploy -n secrets-demo --from=secret/db-creds --prefix=DB_
kubectl get deploy app-deploy -n secrets-demo -o yaml | grep -A4 'name: DB_'
# Same result in YAML (under the app container):
#   env:
#   - name: DB_USERNAME
#     valueFrom: {secretKeyRef: {name: db-creds, key: username}}
#   - name: DB_PASSWORD
#     valueFrom: {secretKeyRef: {name: db-creds, key: password}}
#   - name: DB_DATABASE
#     valueFrom: {secretKeyRef: {name: db-creds, key: database}}
kubectl rollout status deployment/app-deploy -n secrets-demo
kubectl exec deploy/app-deploy -n secrets-demo -- env | grep DB_
kubectl logs deploy/app-deploy -n secrets-demo                  # only "app started"
# Secrets are base64-encoded, not encrypted. Anyone allowed to exec into the pod or read the
# Secret can see the values - control that with RBAC (and encryption at rest for etcd).
```

</details>

## Exam 2 · Q4 – DaemonSet Configuration  (Workloads & Scheduling | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 4
```

**Question**
```text
DaemonSet monitoring-agent in namespace monitoring must run on every node, including the
control plane. Right now the control plane node is missing its agent because of its taint.

Tasks
1. Update the DaemonSet so it tolerates node-role.kubernetes.io/control-plane:NoSchedule
   (keep the image busybox:1.37)
2. Verify one agent pod runs on every node
```

**Validate**
```bash
./mock.sh 2 4 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl describe node controlplane | grep Taints        # node-role.kubernetes.io/control-plane:NoSchedule
kubectl get ds monitoring-agent -n monitoring           # DESIRED = number of worker nodes only
kubectl patch ds monitoring-agent -n monitoring --type=json -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}]'
# or kubectl edit ds monitoring-agent -n monitoring and add under spec.template.spec:
#   tolerations:
#   - key: node-role.kubernetes.io/control-plane
#     operator: Exists
#     effect: NoSchedule
kubectl rollout status ds monitoring-agent -n monitoring
kubectl get pods -n monitoring -o wide                  # one pod per node, incl. controlplane
# (The original exercise used datadog/agent:latest - a >1 GB image that also needs an API key,
#  so this lab uses busybox.)
```

</details>

## Exam 2 · Q5 – API Server Debugging  (Troubleshooting | 9 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 5
```

**Question**
```text
The API server is slow. Audit logging is already enabled:
  policy /etc/kubernetes/audit/policy.yaml, log /var/log/kubernetes/audit/audit.log

Tasks (control plane node)
1. Save the last 50 lines of the kube-apiserver logs to /root/mock2/q05-apiserver.log
2. Save the ss/netstat line that shows kube-apiserver listening on port 6443 to /root/mock2/q05-listen.txt
3. Save the output of the API server's verbose readiness check (/readyz?verbose) to /root/mock2/q05-readyz.txt
4. Using the audit log, find the user that sends the most requests and write the username to
   /root/mock2/q05-top-user.txt
5. Write the HTTP response code that user gets to /root/mock2/q05-code.txt
6. Stop that client: scale its Deployment to 0 replicas (find which one it is)
```

**Validate**
```bash
./mock.sh 2 5 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
# 1. logs - kubectl works while the API server is up; crictl works even when it is down
kubectl logs -n kube-system kube-apiserver-controlplane --tail=50 > /root/mock2/q05-apiserver.log
#   or: crictl logs --tail=50 $(crictl ps --name kube-apiserver -q) > /root/mock2/q05-apiserver.log 2>&1
#   (kubeadm runs it as a static pod - there is no kube-apiserver systemd unit to journalctl)
# 2. listening socket
ss -tlnp | grep 6443 > /root/mock2/q05-listen.txt            # ... *:6443 ... users:(("kube-apiserver",pid=...))
# 3. health
kubectl get --raw='/readyz?verbose' > /root/mock2/q05-readyz.txt
# 4. who sends the most requests? The audit log is JSON lines - one event per line.
jq -r '.user.username' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head -5
#   without jq: grep -o '"username":"[^"]*"' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head
echo system:serviceaccount:reports:report-bot > /root/mock2/q05-top-user.txt
# 5. response codes for that user
grep 'system:serviceaccount:reports:report-bot' /var/log/kubernetes/audit/audit.log | jq -r '.responseStatus.code' | sort | uniq -c
echo 403 > /root/mock2/q05-code.txt
# 6. the username says: ServiceAccount report-bot in namespace reports
kubectl get deploy -n reports -o wide
kubectl scale deploy report-bot -n reports --replicas=0
# Also useful: kubectl get --raw /metrics | grep apiserver_request_total, and APF:
# kubectl get --raw /debug/api_priority_and_fairness/dump_priority_levels
```

</details>

## Exam 2 · Q6 – ConfigMap Updates  (Workloads | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 6
```

**Question**
```text
Namespace config-demo has ConfigMap app-config (key mode=blue) and two Deployments that use it:
  volume-app - mounts the ConfigMap as a volume at /config
  env-app    - reads the key into the environment variable MODE

Tasks
1. Change mode in ConfigMap app-config to green
2. volume-app must pick up the change WITHOUT restarting its pod: verify /config/mode in the
   running pod shows green (this can take up to about a minute)
3. env-app still sees blue. Make it pick up the new value with a rolling restart
   (do not delete or recreate the Deployment)
```

**Validate**
```bash
./mock.sh 2 6 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl patch configmap app-config -n config-demo -p '{"data":{"mode":"green"}}'
#   or: kubectl edit cm app-config -n config-demo
# Volume mounts (without subPath) are refreshed by the kubelet on its next sync - usually < 1 min.
P=$(kubectl get pod -n config-demo -l app=volume-app -o name)
sleep 60; kubectl exec -n config-demo $P -- cat /config/mode            # green, same pod
kubectl logs -n config-demo deploy/volume-app --tail=3
# Environment variables are fixed when the container starts - only a new pod gets the new value:
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # still blue
kubectl rollout restart deployment/env-app -n config-demo
kubectl rollout status deployment/env-app -n config-demo
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # green
# Never updated automatically: env vars, envFrom, and subPath mounts.
# Fully automatic restarts on change need a controller such as Stakater Reloader, or a config
# hash annotation in the pod template that changes whenever the ConfigMap changes.
```

</details>

## Exam 2 · Q7 – PriorityClass and Eviction Order  (Workloads & Scheduling | 9 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 7
```

**Question**
```text
Tasks
1. Create PriorityClass critical-workload with value 1000 and PriorityClass standard-workload
   with value 100. Both use preemptionPolicy PreemptLowerPriority. Neither is the global default.
2. In namespace priority-demo create pods critical-pod-1 and critical-pod-2 (priority class
   critical-workload) and standard-pod (priority class standard-workload), all image nginx:1.27
3. If the node runs out of memory and all three pods use more memory than they request, which
   pod does the kubelet evict first? Write its name to /root/mock2/q07-first-evicted.txt
```

**Validate**
```bash
./mock.sh 2 7 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-workload
value: 1000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Critical workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: standard-workload
value: 100
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Standard workloads"
EOF
for p in critical-pod-1 critical-pod-2; do
  kubectl run $p -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"critical-workload"}}'
done
kubectl run standard-pod -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"standard-workload"}}'
kubectl get pods -n priority-demo -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority
echo standard-pod > /root/mock2/q07-first-evicted.txt
# Two different mechanisms:
# - Preemption (scheduler): a pending higher-priority pod may evict lower-priority pods to fit.
#   preemptionPolicy: Never = the pod waits in the queue but never preempts others.
# - Node-pressure eviction (kubelet): ranks pods by (1) usage above requests, (2) priority,
#   (3) usage relative to requests. All three exceed their requests here, so the lowest
#   priority pod - standard-pod - goes first.
# Setting globalDefault: true would give every new pod without a class that priority - avoid it here.
```

</details>

## Exam 2 · Q8 – Service Types and Exposure  (Services & Networking | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 8
```

**Question**
```text
Deployment legacy-app in namespace legacy (pod label app=legacy) listens on port 3000.
It must be reachable from outside the cluster without an Ingress.

Tasks
1. Create Service legacy-app of type NodePort in namespace legacy:
   service port 8080 -> targetPort 3000, nodePort 30080
2. Verify it answers on <node-ip>:30080 from outside the pod network

(The original task asked for node port 8080. NodePorts must be inside the node port range,
 30000-32767 by default, so 8080 is the service port here.)
```

**Validate**
```bash
./mock.sh 2 8 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: legacy-app
  namespace: legacy
spec:
  type: NodePort
  selector:
    app: legacy
  ports:
  - protocol: TCP
    port: 8080          # ClusterIP port inside the cluster
    targetPort: 3000    # container port
    nodePort: 30080     # opened on every node (30000-32767)
EOF
kubectl get svc legacy-app -n legacy                  # 8080:30080/TCP
kubectl get endpointslices -n legacy
IP=$(kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl http://$IP:30080                                 # legacy-app OK
# kubectl expose deploy legacy-app -n legacy --type=NodePort --port=8080 --target-port=3000
# also works, but picks a random nodePort - patch it to 30080 afterwards.
```

</details>

## Exam 2 · Q9 – CronJob Scheduling  (Workloads | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 9
```

**Question**
```text
Tasks (namespace backup)
1. Create CronJob backup-job: image busybox:1.37, command  sh -c 'echo Running backup; date; sleep 5'
   - runs every day at 02:00
   - keeps only the last 3 successful Jobs
   - restartPolicy OnFailure
2. Suspend the CronJob (it must not run for the next month)
3. While it is suspended, run it once by hand: create Job backup-manual from the CronJob and
   make sure it completes
```

**Validate**
```bash
./mock.sh 2 9 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create cronjob backup-job -n backup --image=busybox:1.37 --schedule="0 2 * * *" \
  --dry-run=client -o yaml -- sh -c 'echo Running backup; date; sleep 5' > backup-job.yaml
# add successfulJobsHistoryLimit + suspend (kubectl create cronjob sets restartPolicy OnFailure already)
sed -i 's/^spec:$/spec:\n  successfulJobsHistoryLimit: 3\n  suspend: true/' backup-job.yaml
kubectl apply -f backup-job.yaml
kubectl get cronjob backup-job -n backup              # SUSPEND True, SCHEDULE 0 2 * * *
# suspend / resume an existing CronJob:
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":true}}'
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":false}}'
kubectl create job backup-manual -n backup --from=cronjob/backup-job
kubectl wait --for=condition=Complete job/backup-manual -n backup
kubectl logs job/backup-manual -n backup
# Cron fields: minute hour day-of-month month day-of-week. Times use the controller-manager's time
# zone unless you set spec.timeZone (e.g. "Etc/UTC").
```

</details>

## Exam 2 · Q10 – Cluster Certificate Rotation  (Cluster Architecture | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 10
```

**Question**
```text
The control plane certificates expire soon. On the control plane node:

Tasks
1. Save the current expiration overview (kubeadm) to /root/mock2/q10-before.txt
2. Renew all kubeadm-managed certificates
3. Make the control plane components use the new certificates - the API server on port 6443
   must serve the renewed certificate
4. Make sure kubectl still works afterwards
```

**Validate**
```bash
./mock.sh 2 10 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubeadm certs check-expiration | tee /root/mock2/q10-before.txt
kubeadm certs renew all
#   "Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager,
#    kube-scheduler and etcd, so that they can use the new certificates."
kubeadm certs check-expiration                       # new dates
# Restart the static pods: move the manifests out, wait until the containers are gone, move them back.
# (systemctl restart kubelet does NOT restart running static pod containers, and
#  kubectl delete pod on a mirror pod does not restart the container either.)
mkdir -p /root/manifests-tmp
mv /etc/kubernetes/manifests/*.yaml /root/manifests-tmp/
sleep 20; crictl ps | grep -E 'kube-apiserver|etcd|kube-scheduler|kube-controller' || echo "all stopped"
mv /root/manifests-tmp/*.yaml /etc/kubernetes/manifests/
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
# admin.conf was renewed too - refresh your kubeconfig
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl get nodes
echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -dates
# The CA certificates (10 years) are not renewed by "renew all". kubelet client certs rotate by themselves.
```

</details>

## Exam 2 · Q11 – Pod Disruption Budgets  (Workloads & Scheduling | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 11
```

**Question**
```text
Deployment my-app in namespace pdb-demo runs 10 replicas (label app=my-app). It may never lose
more than 2 pods at once to voluntary disruptions such as node drains.

Tasks
1. Create PodDisruptionBudget app-pdb in pdb-demo that enforces this
2. Test it: drain node01 (ignore DaemonSets, use --timeout=60s) and watch the evictions get blocked
3. Uncordon node01 afterwards and make sure all 10 replicas are available again
```

**Validate**
```bash
./mock.sh 2 11 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create pdb app-pdb -n pdb-demo --selector=app=my-app --min-available=8
#   (equivalent: --max-unavailable=2)
kubectl get pdb app-pdb -n pdb-demo                 # ALLOWED DISRUPTIONS 2
kubectl drain node01 --ignore-daemonsets --timeout=60s
#   evicting pod pdb-demo/my-app-...
#   error when evicting pods/"my-app-..." -n "pdb-demo" (will retry after 5s): Cannot evict pod as it
#   would violate the pod's disruption budget.
# Drain evicts 2 pods, then waits until replacements are Ready elsewhere before evicting more.
# If the replacements can't start (e.g. the control plane is tainted), the drain stops at the budget.
kubectl get pods -n pdb-demo -o wide
kubectl uncordon node01
kubectl rollout status deploy/my-app -n pdb-demo
kubectl get pdb app-pdb -n pdb-demo
# A PDB only limits voluntary disruptions that use the Eviction API (drain, kubectl evict).
# kubectl delete pod and node failures ignore it.
```

</details>

## Exam 2 · Q12 – Custom Resource Definitions  (Cluster Architecture | 7 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 12
```

**Question**
```text
Your team installed a CRD for the kind Database.

Tasks
1. Find the CRD and write its full name to /root/mock2/q12-crd.txt
2. In namespace crd-demo create a Database named prod-db with
     spec.engine=postgres  spec.version="15"  spec.storage=100Gi
3. Show that prod-db is stored in etcd: save the output of an etcdctl get for its key
   (--keys-only is enough) to /root/mock2/q12-etcd.txt
4. Delete the Database old-db in crd-demo
```

**Validate**
```bash
./mock.sh 2 12 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl get crd | grep -i database
kubectl get crd databases.example.com -o jsonpath='{.metadata.name}' > /root/mock2/q12-crd.txt
kubectl explain database.spec                     # fields: engine (postgres|mysql), version, storage
cat <<'EOF' | kubectl apply -f -
apiVersion: example.com/v1
kind: Database
metadata:
  name: prod-db
  namespace: crd-demo
spec:
  engine: postgres
  version: "15"          # quoted - the schema says string
  storage: 100Gi
EOF
kubectl get databases -n crd-demo                 # short name: kubectl get db -n crd-demo
# etcd keys: /registry/<group>/<plural>/<namespace>/<name>
# etcdctl from the etcd container (works even if etcdctl is not installed on the node):
ETCD=$(crictl ps --name etcd -q | head -1)
crictl exec $ETCD etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/example.com/databases/crd-demo/prod-db --keys-only | tee /root/mock2/q12-etcd.txt
kubectl delete database old-db -n crd-demo
kubectl get databases -n crd-demo
```

</details>

## Exam 2 · Q13 – Pod Security Exceptions  (Cluster Architecture | 9 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 13
```

**Question**
```text
Namespace restricted enforces the restricted Pod Security Standard. A legacy pod root-app
(image nginx:1.27, must run as root) is rejected there.

Pod Security Admission has no per-pod exemption label: exemptions exist only in the API server's
admission configuration (by user, runtimeClass or namespace). Solve it with namespaces instead:

Tasks
1. Create namespace legacy-root that enforces the baseline Pod Security Standard
   (root is allowed, privileged containers are not)
2. Run pod root-app (nginx:1.27) there and verify it runs as uid 0
3. Leave namespace restricted unchanged: it must still reject a root pod
```

**Validate**
```bash
./mock.sh 2 13 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Exam 2 · Q14 – StorageClass and Dynamic Provisioning  (Storage | 8 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 14
```

**Question**
```text
The cluster runs the local-path provisioner (provisioner name rancher.io/local-path).

Tasks
1. Create StorageClass ssd: provisioner rancher.io/local-path, reclaimPolicy Delete,
   volumeBindingMode WaitForFirstConsumer
2. In namespace storage-demo create PVC my-ssd-claim: 20Gi, ReadWriteOnce, storageClassName ssd
3. Create pod app-using-ssd (image nginx:1.27) in storage-demo that mounts the claim at /data
4. Verify a PersistentVolume was created automatically and the claim is Bound
```

**Validate**
```bash
./mock.sh 2 14 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-ssd-claim
  namespace: storage-demo
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: ssd
  resources:
    requests:
      storage: 20Gi
EOF
kubectl get pvc -n storage-demo              # Pending - WaitForFirstConsumer waits for a pod
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-using-ssd
  namespace: storage-demo
spec:
  containers:
  - name: app
    image: nginx:1.27
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-ssd-claim
EOF
kubectl wait --for=condition=Ready pod/app-using-ssd -n storage-demo
kubectl get pvc,pv -n storage-demo           # Bound, PV pvc-<uid> created by the provisioner
# On a cloud cluster the provisioner would be the CSI driver, e.g. ebs.csi.aws.com (type: gp3)
# or pd.csi.storage.gke.io (type: pd-ssd). local-path does not enforce the 20Gi size.
```

</details>

## Exam 2 · Q15 – Namespace Quota and Resource Management  (Workloads & Scheduling | 10 min)

**Setup** (only needed if you run this question on its own)
```bash
./mock.sh 2 15
```

**Question**
```text
Set up resource governance for namespace batch-jobs.

Tasks
1. ResourceQuota batch-quota: total CPU 10 cores and total memory 20Gi
   (for requests; you may also cap limits at the same values)
2. LimitRange batch-limits, per container: minimum 500m CPU / 256Mi memory,
   maximum 4 CPU / 8Gi memory
3. Try to create a pod that requests (and limits) 5 CPU / 2Gi - it must be rejected.
   Save the error to /root/mock2/q15-rejected.txt
4. Verify a pod with requests 1 CPU / 1Gi and limits 2 CPU / 2Gi is accepted
```

**Validate**
```bash
./mock.sh 2 15 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: batch-quota
  namespace: batch-jobs
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "10"
    limits.memory: 20Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: batch-limits
  namespace: batch-jobs
spec:
  limits:
  - type: Container
    min:
      cpu: 500m
      memory: 256Mi
    max:
      cpu: "4"
      memory: 8Gi
EOF
kubectl describe quota batch-quota -n batch-jobs
kubectl describe limitrange batch-limits -n batch-jobs
# kubectl run lost --requests/--limits in 1.24 - use --overrides (or YAML):
kubectl run too-big -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"too-big","image":"nginx:1.27","resources":{"requests":{"cpu":"5","memory":"2Gi"},"limits":{"cpu":"5","memory":"2Gi"}}}]}}' 2> /root/mock2/q15-rejected.txt
cat /root/mock2/q15-rejected.txt     # forbidden: maximum cpu usage per Container is 4, but limit is 5
kubectl run fits -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"fits","image":"nginx:1.27","resources":{"requests":{"cpu":"1","memory":"1Gi"},"limits":{"cpu":"2","memory":"2Gi"}}}]}}'
kubectl get pod fits -n batch-jobs
# LimitRange max with no default: containers without limits get limits = max (4 CPU / 8Gi) and,
# if requests are missing too, requests = those limits.
```

</details>
