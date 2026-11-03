# CKA Killercoda Labs – Questions

31 practice labs. Each lab has a setup command, the question, a validate command and a hidden solution.

## Setup (once per Killercoda session)

```bash
git clone https://github.com/norbutlepcha25/CKA-Killercoda-Labs.git
cd CKA-Killercoda-Labs
chmod +x lab.sh lib/*.sh Question-*/*.sh Question-*/LabSetUp.bash
./lab.sh list
```

## Q1 – Pod Basics  (Workloads & Scheduling | Easy | 10 min)

**Setup**
```bash
./lab.sh 1
```

**Question**
```text
Create a pod with specific resource requests, labels, and verify it's running.

Tasks
1. Create a namespace called exercise-01
2. Create a pod named web in namespace exercise-01 with:
   - Image: nginx:1.27
   - Labels: app=web, tier=frontend
   - Resource requests: 64Mi memory, 100m CPU
   - Resource limits: 128Mi memory, 250m CPU
3. Verify the pod is running and has the correct labels
4. Get the pod's IP address using -o wide
5. Add a new label version=v1 to the running pod
6. Remove the tier label from the pod
```

**Validate**
```bash
./lab.sh 1 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-01
kubectl run web -n exercise-01 --image=nginx:1.27 --labels=app=web,tier=frontend --dry-run=client -o yaml > pod.yaml
# edit pod.yaml and add the resources block - the finished file:
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: exercise-01
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: web
    image: nginx:1.27
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "250m"
EOF
kubectl apply -f pod.yaml
kubectl get pod web -n exercise-01 --show-labels
kubectl get pod web -n exercise-01 -o wide
kubectl label pod web -n exercise-01 version=v1
kubectl label pod web -n exercise-01 tier-
```

</details>

## Q2 – Multi-Container Pod / Native Sidecar  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 2
```

**Question**
```text
Tasks
1. Create a namespace called exercise-02
2. Create a pod named logger in namespace exercise-02 with:
   - An init container (sidecar) named log-agent using busybox:1.36
     - Set restartPolicy: Always on the init container to make it a native sidecar
     - Command: tail -F /var/log/app/app.log   (capital F waits for file creation)
     - Mount a shared volume at /var/log/app
   - A main container named app using busybox:1.36
     - Command: write a line to /var/log/app/app.log every 3 seconds
     - Mount the same shared volume at /var/log/app
   - Use an emptyDir volume named log-volume
3. Verify both containers are running (READY 2/2)
4. Check the sidecar's logs to see the streamed output
```

**Validate**
```bash
./lab.sh 2 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-02
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logger
  namespace: exercise-02
spec:
  initContainers:
  - name: log-agent
    image: busybox:1.36
    restartPolicy: Always
    command: ["sh", "-c", "tail -F /var/log/app/app.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo \"$(date) - app running\" >> /var/log/app/app.log; sleep 3; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
kubectl get pod logger -n exercise-02          # READY 2/2
kubectl logs logger -n exercise-02 -c log-agent
```

</details>

## Q3 – ConfigMap & Secret  (Workloads & Scheduling | Easy | 10 min)

**Setup**
```bash
./lab.sh 3
```

**Question**
```text
Tasks
1. Create a namespace called exercise-03
2. Create a ConfigMap named app-config with:
   - Key APP_MODE = production
   - Key LOG_LEVEL = debug
3. Create a Secret named db-creds with:
   - Key DB_USER = admin
   - Key DB_PASS = s3cretP@ss
4. Create a pod named app that:
   - Uses image busybox:1.36, command sleep 3600
   - Loads APP_MODE and LOG_LEVEL from the ConfigMap as env vars
   - Loads DB_USER and DB_PASS from the Secret as env vars
   - Mounts the entire ConfigMap as files at /etc/config/
5. Verify the env vars are set inside the pod
6. Verify the mounted files exist at /etc/config/
```

**Validate**
```bash
./lab.sh 3 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-03
kubectl create configmap app-config -n exercise-03 --from-literal=APP_MODE=production --from-literal=LOG_LEVEL=debug
kubectl create secret generic db-creds -n exercise-03 --from-literal=DB_USER=admin --from-literal='DB_PASS=s3cretP@ss'
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: exercise-03
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-creds
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF
kubectl exec app -n exercise-03 -- env | grep -E "APP_MODE|LOG_LEVEL|DB_USER|DB_PASS"
kubectl exec app -n exercise-03 -- ls /etc/config/
```

</details>

## Q4 – RBAC  (Cluster Architecture | Medium | 15 min)

**Setup**
```bash
./lab.sh 4
```

**Question**
```text
Tasks
1. Create a namespace called exercise-04
2. Create a ServiceAccount named dev-sa in namespace exercise-04
3. Create a Role named pod-manager in namespace exercise-04 that allows:
   - get, list, watch, create, delete on pods
   - get, list on services
4. Create a RoleBinding named dev-pod-access that binds pod-manager to dev-sa
5. Verify that dev-sa can list pods in exercise-04
6. Verify that dev-sa cannot list pods in the default namespace
7. Create a ClusterRole named node-viewer that allows get, list on nodes
8. Create a ClusterRoleBinding named dev-node-access binding node-viewer to dev-sa
9. Verify that dev-sa can now list nodes

Additional real-exam scenarios
10. A developer reports they cannot delete a deployment in exercise-04. Use kubectl auth can-i to debug why
11. Test what dev-sa can do with deployments (should return "no")
12. List all permissions granted to dev-sa in the exercise-04 namespace
```

**Validate**
```bash
./lab.sh 4 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-04
kubectl create sa dev-sa -n exercise-04
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-manager
  namespace: exercise-04
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "delete"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
EOF
kubectl create rolebinding dev-pod-access -n exercise-04 --role=pod-manager --serviceaccount=exercise-04:dev-sa
AS=system:serviceaccount:exercise-04:dev-sa
kubectl auth can-i list pods -n exercise-04 --as=$AS       # yes
kubectl auth can-i list pods -n default --as=$AS           # no
kubectl create clusterrole node-viewer --verb=get,list --resource=nodes
kubectl create clusterrolebinding dev-node-access --clusterrole=node-viewer --serviceaccount=exercise-04:dev-sa
kubectl auth can-i list nodes --as=$AS                     # yes
kubectl auth can-i delete deployments -n exercise-04 --as=$AS   # no - Role has no apps/deployments rule
kubectl auth can-i --list -n exercise-04 --as=$AS
```

</details>

## Q5 – NetworkPolicy  (Services & Networking | Medium | 20 min)

**Setup**
```bash
./lab.sh 5
```

**Question**
```text
Tasks
1. Create a namespace called exercise-05
2. Deploy two pods:
   - frontend with image nginx:1.27 and label role=frontend
   - backend  with image nginx:1.27 and label role=backend
3. Verify that frontend can reach backend on port 80 (should work before any policy)
4. Create a NetworkPolicy named backend-policy that:
   - Applies to pods with label role=backend
   - Allows ingress only from pods with label role=frontend on port 80
   - Allows egress to DNS (UDP port 53) - if you skip this, DNS breaks
5. Verify that frontend can still reach backend
6. Create a third pod attacker (image nginx:1.27, label role=attacker) and verify it cannot reach backend
```

**Validate**
```bash
./lab.sh 5 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-05
kubectl run frontend -n exercise-05 --image=nginx:1.27 --labels=role=frontend
kubectl run backend  -n exercise-05 --image=nginx:1.27 --labels=role=backend
kubectl run attacker -n exercise-05 --image=nginx:1.27 --labels=role=attacker
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: exercise-05
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - ports:
    - protocol: UDP
      port: 53
EOF
BACKEND_IP=$(kubectl get pod backend -n exercise-05 -o jsonpath='{.status.podIP}')
kubectl exec frontend -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # works
kubectl exec attacker -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # times out
```

</details>

## Q6 – Deployment Rolling Update and Rollback  (Workloads & Scheduling | Easy | 10 min)

**Setup**
```bash
./lab.sh 6
```

**Question**
```text
Tasks
1. Create a namespace called exercise-06
2. Create a Deployment named webapp with:
   - 3 replicas
   - Image: nginx:1.28
   - Strategy: RollingUpdate with maxSurge=1, maxUnavailable=0
   - Record the change cause (annotation kubernetes.io/change-cause)
3. Verify all 3 replicas are running
4. Update the image to nginx:1.29 and record the change
5. Watch the rollout status
6. Check rollout history - you should see 2 revisions
7. Rollback to the previous version (nginx:1.28)
8. Verify the rollback worked by checking the image
```

**Validate**
```bash
./lab.sh 6 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-06
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: exercise-06
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
EOF
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="initial deploy nginx:1.28"
kubectl set image deployment/webapp nginx=nginx:1.29 -n exercise-06
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="update to nginx:1.29" --overwrite
kubectl rollout status deployment/webapp -n exercise-06
kubectl rollout history deployment/webapp -n exercise-06
kubectl rollout undo deployment/webapp -n exercise-06
kubectl get deploy webapp -n exercise-06 -o jsonpath='{.spec.template.spec.containers[0].image}'   # nginx:1.28
```

</details>

## Q7 – StatefulSet  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 7
```

**Question**
```text
Work in the default namespace.

Tasks
1. Create a headless Service named mysql (port 3306, selector app=mysql) for the StatefulSet
2. Create a StatefulSet named mysql with 3 replicas using the nginx:1.28 image
   - serviceName: mysql, label app=mysql, containerPort 3306 named mysql
   - volumeClaimTemplate named data (ReadWriteOnce, 1Gi) mounted at /data
3. Verify pods start in order (mysql-0 first, then mysql-1, then mysql-2)
4. Verify each pod has a PersistentVolumeClaim attached
5. Delete a pod and observe it respawn with the same name and storage
6. Scale the StatefulSet up and down using kubectl scale
7. Delete the StatefulSet and verify the PVCs persist (data survives)
```

**Validate**
```bash
./lab.sh 7 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    name: mysql
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF
kubectl get pods -l app=mysql -w            # mysql-0, mysql-1, mysql-2 in order
kubectl get pvc                             # data-mysql-0/1/2
kubectl run debug --image=busybox:1.36 --rm -it --restart=Never -- nslookup mysql-0.mysql.default.svc.cluster.local
kubectl delete pod mysql-1 && kubectl get pods -l app=mysql   # mysql-1 comes back
kubectl scale statefulset mysql --replicas=4
kubectl scale statefulset mysql --replicas=2
kubectl delete statefulset mysql
kubectl get pvc                             # PVCs are still there
```

</details>

## Q8 – Node Drain and Cordon  (Cluster Architecture | Easy | 10 min)

**Setup**
```bash
./lab.sh 8
```

**Question**
```text
Work in the default namespace. The worker node on Killercoda is node01.

Tasks
1. List all nodes and identify a worker node
2. Cordon the worker node (mark it unschedulable)
3. Verify the node shows SchedulingDisabled
4. Create a Deployment named drain-test (image nginx:1.27, 3 replicas) and observe where pods are scheduled
5. Drain the worker node - handle DaemonSets and local data
6. Verify all non-DaemonSet pods have been evicted from the node
7. Uncordon the node
8. Scale the deployment to 6 replicas and verify pods get scheduled on the uncordoned node
```

**Validate**
```bash
./lab.sh 8 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Q9 – kubeadm Cluster Upgrade  (Cluster Architecture | Hard | 25 min)

**Setup**
```bash
./lab.sh 9
```

**Question**
```text
The lab setup prepared the apt repository on both nodes.
Target version:  cat /root/upgrade-target.txt          (e.g. v1.36.0)
Apt package:     cat /root/upgrade-target-package.txt  (e.g. 1.36.0-1.1)

Tasks
1. Check the current cluster version (kubectl get nodes, kubeadm version)
2. Upgrade the control plane node (controlplane) to the target version:
   a. Update the kubeadm package to the target version
   b. Run kubeadm upgrade plan to see available upgrades
   c. Run kubeadm upgrade apply <target version>
   d. Upgrade the kubelet and kubectl packages
   e. Restart kubelet
3. Upgrade the worker node (node01):
   a. Drain the worker node
   b. Update the kubeadm, kubelet, kubectl packages on the worker
   c. Run kubeadm upgrade node
   d. Restart kubelet
   e. Uncordon the worker
4. Verify all nodes show the new version

Note: an upgrade cannot be undone. Start a fresh Killercoda session to practise it again.
```

**Validate**
```bash
./lab.sh 9 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
VER=$(cat /root/upgrade-target.txt); PKG=$(cat /root/upgrade-target-package.txt)

# === CONTROL PLANE (controlplane) ===
kubectl drain controlplane --ignore-daemonsets          # optional but recommended
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=$PKG
apt-mark hold kubeadm
kubeadm version
kubeadm upgrade plan
kubeadm upgrade apply $VER -y
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=$PKG kubectl=$PKG
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon controlplane
kubectl get nodes

# === WORKER (node01) ===
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
ssh node01
  PKG=<paste the package version>
  apt-mark unhold kubeadm kubelet kubectl
  apt-get update && apt-get install -y kubeadm=$PKG kubelet=$PKG kubectl=$PKG
  apt-mark hold kubeadm kubelet kubectl
  kubeadm upgrade node
  systemctl daemon-reload && systemctl restart kubelet
  exit
kubectl uncordon node01
kubectl get nodes          # both nodes on the new version

# Remember: control plane = kubeadm upgrade apply, worker = kubeadm upgrade node
```

</details>

## Q10 – Static Pod  (Workloads & Scheduling | Easy | 10 min)

**Setup**
```bash
./lab.sh 10
```

**Question**
```text
Work on the control plane node (controlplane).

Tasks
1. Find the static pod manifest directory on the node
2. Create a static pod manifest file for a pod named static-web with:
   - Image: nginx:1.27
   - Port: 80
3. Verify the static pod appears in kubectl get pods (it will have the node name appended)
   -> run ./lab.sh 10 validate now to check this part
4. Try to delete the static pod with kubectl - observe what happens
5. Delete the static pod by removing the manifest file
6. Verify the pod is gone
   -> run ./lab.sh 10 validate again
```

**Validate**
```bash
./lab.sh 10 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
grep staticPodPath /var/lib/kubelet/config.yaml      # /etc/kubernetes/manifests
cat <<'EOF' > /etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    app: static-web
spec:
  containers:
  - name: web
    image: nginx:1.27
    ports:
    - containerPort: 80
EOF
kubectl get pods | grep static-web                   # static-web-controlplane
kubectl delete pod static-web-controlplane           # it comes back (mirror pod)
rm /etc/kubernetes/manifests/static-web.yaml
kubectl get pods | grep static-web                   # gone
```

</details>

## Q11 – Troubleshoot Cluster Components  (Troubleshooting | Hard | 25 min)

**Setup**
```bash
./lab.sh 11
```

**Question**
```text
The lab setup has broken the cluster. Find and fix every problem.

Scenario A: Broken kubelet
1. A worker node is NotReady. Identify which node and why
2. SSH to it and check the kubelet service status and logs
3. Fix it so the node is Ready - and stays fixed after a reboot

Scenario B: CoreDNS troubleshooting
1. Create a pod and try to resolve a service name (kubernetes.default) - it fails
2. Check the CoreDNS pods in kube-system
3. Check that the kube-dns service has endpoints
4. Check the CoreDNS logs for errors
5. Verify the CoreDNS ConfigMap for misconfigurations
6. Fix all issues and verify DNS resolution works

Scenario C: kube-proxy (investigate only)
1. Check if kube-proxy pods are running on all nodes
2. Check kube-proxy logs
3. Verify the kube-proxy ConfigMap
4. Check iptables rules on a node

Scenario D: API server audit logs (investigate only)
1. Check the kube-apiserver manifest for audit flags (--audit-policy-file, --audit-log-path)
2. Killercoda does not enable audit logging by default - note which flags and volume
   mounts you would add to enable it, and where the log file would be written
```

**Validate**
```bash
./lab.sh 11 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
# ---- Scenario A: kubelet ----
kubectl get nodes                              # node01 NotReady
ssh node01
  systemctl status kubelet                     # inactive (dead), disabled
  journalctl -u kubelet --no-pager | tail -20
  systemctl enable --now kubelet               # enable = survives reboot
  exit
kubectl get nodes                              # node01 Ready

# ---- Scenario B: CoreDNS ----
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # fails
kubectl get pods -n kube-system -l k8s-app=kube-dns        # no pods
kubectl get endpoints kube-dns -n kube-system              # no endpoints
kubectl get deploy coredns -n kube-system                  # 0/0 replicas
kubectl scale deploy coredns -n kube-system --replicas=2
kubectl get pods -n kube-system -l k8s-app=kube-dns        # CrashLoopBackOff
kubectl logs -n kube-system -l k8s-app=kube-dns            # Unknown directive 'kubernetess'
kubectl edit cm coredns -n kube-system                     # kubernetess -> kubernetes
kubectl rollout restart deploy coredns -n kube-system
kubectl get endpoints kube-dns -n kube-system              # IPs listed
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # works

# ---- Scenario C: kube-proxy ----
kubectl get ds kube-proxy -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=20
kubectl get cm kube-proxy -n kube-system -o yaml
iptables-save | grep -c KUBE

# ---- Scenario D: audit logs ----
grep -i audit /etc/kubernetes/manifests/kube-apiserver.yaml   # nothing on Killercoda
# To enable you would add, for example:
#   - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxage=7
# plus hostPath volumes + volumeMounts for the policy file and the log directory.
# Then: tail /var/log/kubernetes/audit/audit.log | jq 'select(.responseStatus.code>=400)'
```

</details>

## Q12 – Storage: PV, PVC and Pod  (Storage | Medium | 15 min)

**Setup**
```bash
./lab.sh 12
```

**Question**
```text
Tasks
1. Create a namespace called exercise-12
2. Create a PersistentVolume named my-pv with:
   - Capacity: 1Gi
   - AccessMode: ReadWriteOnce
   - StorageClass: manual
   - hostPath: /data/exercise-12
   - Reclaim policy: Retain
3. Create a PersistentVolumeClaim named my-pvc in namespace exercise-12:
   - Request: 500Mi
   - AccessMode: ReadWriteOnce
   - StorageClass: manual
4. Create a pod named storage-consumer (busybox, sleep 3600) that mounts my-pvc at /data
5. Verify:
   - The PVC is Bound to the PV
   - The Pod is Running (not stuck Pending)
6. Write a test file /data/test.txt inside the mounted volume from the Pod
7. Delete the pod, create a new pod with the same PVC, and verify the file persists
8. Delete the pod and the PVC and check the PV status (should be Released, not Available, because the policy is Retain)
```

**Validate**
```bash
./lab.sh 12 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-12
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data/exercise-12
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: exercise-12
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi
EOF
kubectl get pvc my-pvc -n exercise-12          # Bound
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-consumer
  namespace: exercise-12
spec:
  nodeName: node01               # keeps the pod on the same node so the hostPath data is there
  containers:
  - name: consumer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
EOF
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- sh -c 'echo "data persists" > /data/test.txt'
kubectl delete pod storage-consumer -n exercise-12 && kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- cat /data/test.txt   # data persists
kubectl delete pod storage-consumer -n exercise-12
kubectl delete pvc my-pvc -n exercise-12
kubectl get pv my-pv                            # Released
# Note: hostPath is node-local. Pinning the pod (nodeName/nodeSelector) keeps both pods on one node.
```

</details>

## Q13 – Helm Install, Upgrade and Rollback  (Cluster Architecture | Medium | 15 min)

**Setup**
```bash
./lab.sh 13
```

**Question**
```text
Tasks
1. Add the Bitnami chart repository (name bitnami, https://charts.bitnami.com/bitnami) and update the repo cache
2. Install NGINX (chart bitnami/nginx) using Helm in a namespace called exercise-13:
   - Release name: web
   - Set replicaCount=2
3. Verify the release is deployed and 2 pods are running
4. Upgrade the release to replicaCount=3
5. Check the release history and confirm there are 2 revisions
6. Roll back to revision 1
7. Verify the replica count is back to 2
```

**Validate**
```bash
./lab.sh 13 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install web bitnami/nginx -n exercise-13 --create-namespace --set replicaCount=2
helm list -n exercise-13
kubectl get pods -n exercise-13
helm upgrade web bitnami/nginx -n exercise-13 --reuse-values --set replicaCount=3
helm history web -n exercise-13                # 2 revisions
helm rollback web 1 -n exercise-13
kubectl get deploy -n exercise-13 -o jsonpath='{.items[0].spec.replicas}'   # 2
helm history web -n exercise-13                # 3 rows, last = "Rollback to 1"

# If the pods are stuck in ImagePullBackOff: Bitnami moved most free images to
# docker.io/bitnamilegacy in 2025. Add these flags to the install/upgrade:
#   --set image.repository=bitnamilegacy/nginx --set global.security.allowInsecureImages=true
# The Helm tasks (install/upgrade/history/rollback) are what is being tested.
```

</details>

## Q14 – Kustomize: Base and Overlay  (Cluster Architecture | Medium | 15 min)

**Setup**
```bash
./lab.sh 14
```

**Question**
```text
Tasks
1. Create this directory structure under /root:
     /root/kustomize-lab/
       base/
         deployment.yaml
         service.yaml
         kustomization.yaml
       overlays/
         staging/
           kustomization.yaml
2. In the base:
   - A Deployment named app with image nginx:1.27 and 1 replica
   - A ClusterIP Service named app-svc on port 80
   - A kustomization.yaml listing both resources
3. In the staging overlay:
   - Set the namespace to exercise-14
   - Patch replicas to 3
   - Add a common label env: staging
4. Create namespace exercise-14
5. Apply the staging overlay with kubectl apply -k
6. Verify 3 pods are running in namespace exercise-14 with label env=staging
```

**Validate**
```bash
./lab.sh 14 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
mkdir -p /root/kustomize-lab/base /root/kustomize-lab/overlays/staging
cd /root/kustomize-lab
cat <<'EOF' > base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
EOF
cat <<'EOF' > base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  selector:
    app: app
  ports:
  - port: 80
    targetPort: 80
EOF
cat <<'EOF' > base/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF
cat <<'EOF' > overlays/staging/kustomization.yaml
resources:
- ../../base
namespace: exercise-14
labels:
- pairs:
    env: staging
  includeSelectors: true
  includeTemplates: true
replicas:
- name: app
  count: 3
EOF
kubectl create ns exercise-14
kubectl kustomize overlays/staging          # preview
kubectl apply -k overlays/staging
kubectl get pods -n exercise-14 -l env=staging
# (commonLabels: {env: staging} also works but is deprecated)
```

</details>

## Q15 – Gateway API: Gateway and HTTPRoute  (Services & Networking | Medium | 20 min)

**Setup**
```bash
./lab.sh 15
```

**Question**
```text
The lab setup installed Envoy Gateway and a GatewayClass named eg.

Tasks
1. Create a namespace called exercise-15
2. Verify a GatewayClass exists in the cluster
3. Create a Gateway named web-gateway in namespace exercise-15:
   - Reference the existing GatewayClass
   - Listen on port 80, protocol HTTP
4. Create a Deployment named web with image nginx:1.28 and 2 replicas
5. Expose it with a ClusterIP Service named web-svc on port 80
6. Create an HTTPRoute named web-route that:
   - References web-gateway as the parent
   - Matches path prefix /
   - Routes to web-svc on port 80
7. Verify the Gateway status shows Programmed: True
8. Verify the HTTPRoute is attached to the Gateway
Bonus: send a request through the gateway (Envoy is exposed as a NodePort Service in envoy-gateway-system)
```

**Validate**
```bash
./lab.sh 15 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-15
kubectl get gatewayclass                      # eg
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: exercise-15
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF
kubectl create deployment web -n exercise-15 --image=nginx:1.28 --replicas=2
kubectl expose deployment web -n exercise-15 --name=web-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: exercise-15
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-svc
      port: 80
EOF
kubectl get gateway web-gateway -n exercise-15          # PROGRAMMED True
kubectl describe httproute web-route -n exercise-15     # Accepted / ResolvedRefs True
# Bonus test through the gateway:
SVC=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway -o jsonpath='{.items[0].metadata.name}')
NP=$(kubectl get svc $SVC -n envoy-gateway-system -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s http://node01:$NP | head -4
```

</details>

## Q16 – Horizontal Pod Autoscaler  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 16
```

**Question**
```text
The lab setup installed metrics-server.

Tasks
1. Create a namespace called exercise-16
2. Verify the metrics-server is running in the cluster
3. Create a Deployment named load-app with:
   - Image: registry.k8s.io/hpa-example (or nginx:1.27)
   - 1 replica
   - CPU request: 50m
   - CPU limit: 100m
4. Expose it with a ClusterIP Service named load-svc on port 80
5. Create an HPA targeting load-app:
   - Min replicas: 1
   - Max replicas: 5
   - Target CPU utilization: 50% (type: Utilization, averageUtilization: 50)
6. Verify the HPA YAML has the correct structure (target type is Utilization, not AverageValue)
7. Generate load against the service and observe the HPA scaling up
8. Stop the load and observe the HPA scaling back down
```

**Validate**
```bash
./lab.sh 16 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-16
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-app
  namespace: exercise-16
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-app
  template:
    metadata:
      labels:
        app: load-app
    spec:
      containers:
      - name: app
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "50m"
          limits:
            cpu: "100m"
EOF
kubectl expose deployment load-app -n exercise-16 --name=load-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: load-app
  namespace: exercise-16
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF
# (imperative alternative: kubectl autoscale deployment load-app -n exercise-16 --cpu-percent=50 --min=1 --max=5)
kubectl get hpa load-app -n exercise-16 -o yaml | grep -A4 target:
# terminal 1 - generate load:
kubectl run load-gen -n exercise-16 --image=busybox:1.36 --rm -it --restart=Never -- sh -c "while true; do wget -q -O- http://load-svc; done"
# terminal 2 - watch:
kubectl get hpa -n exercise-16 -w
# Ctrl+C the load, wait ~5 min for scale-down
```

</details>

## Q17 – kubectl debug: Pod and Node  (Troubleshooting | Medium | 15 min)

**Setup**
```bash
./lab.sh 17
```

**Question**
```text
Part A: Debug a pod
1. Create a namespace called exercise-17
2. Create a pod named broken-app with image nginx:1.27
3. Attach a debug container to the running pod using kubectl debug:
   - Image: busybox:1.36
   - Target the broken-app container to share its process namespace
4. From inside the debug container, list the processes (you should see the nginx process)
5. Check the filesystem and network from the debug container
6. Exit the debug session

Part B: Debug a node
7. Run kubectl debug against a node (e.g. node01) to get a shell with host filesystem access
8. Use chroot /host to access the real node root
9. Check kubelet status from the debug session
10. Exit the debug session (leave the node-debugger pod in place for validation)
```

**Validate**
```bash
./lab.sh 17 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
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
```

</details>

## Q18 – CRI-dockerd Installation from the release binary  (Cluster Architecture | Medium | 15 min)

**Setup**
```bash
./lab.sh 18
```

**Question**
```text
Do this on the worker node:  ssh node01

Tasks
1. Load the required kernel modules: overlay and br_netfilter
2. Configure kernel networking parameters via sysctl (persistently, in /etc/sysctl.d/):
   net.bridge.bridge-nf-call-iptables = 1, net.ipv4.ip_forward = 1, net.ipv6.conf.all.forwarding = 1
3. Install Docker (required dependency for CRI-dockerd) - skip if docker is already installed
4. Download and install the CRI-dockerd binary (v0.3.20 .tgz) from GitHub releases to /usr/local/bin
5. Create systemd unit files for cri-docker.service and cri-docker.socket
6. Enable and start the cri-docker services
7. Verify the CRI-dockerd socket is listening at /run/cri-dockerd.sock
```

**Validate**
```bash
./lab.sh 18 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
ssh node01
modprobe overlay && modprobe br_netfilter
cat <<'EOF' > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
cat <<'EOF' > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system
command -v docker || { apt-get update && apt-get install -y docker.io; }
systemctl enable --now docker

VER=0.3.20
wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xzf cri-dockerd-${VER}.amd64.tgz
install -m 0755 cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
cri-dockerd --version

cat <<'EOF' > /etc/systemd/system/cri-docker.service
[Unit]
Description=CRI Interface for Docker Application Container Engine
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
EOF
cat <<'EOF' > /etc/systemd/system/cri-docker.socket
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
systemctl daemon-reload
systemctl enable --now cri-docker.socket cri-docker.service
systemctl status cri-docker.service cri-docker.socket --no-pager
ls -la /run/cri-dockerd.sock
crictl --runtime-endpoint unix:///run/cri-dockerd.sock version
# kubeadm join ... --cri-socket unix:///run/cri-dockerd.sock   (how you would use it)
```

</details>

## Q19 – Classic Ingress  (Services & Networking | Medium | 15 min)

**Setup**
```bash
./lab.sh 19
```

**Question**
```text
The lab setup installed the ingress-nginx controller (IngressClass nginx).

Tasks
1. Create a namespace called exercise-19
2. Create two Deployments:
   - web-app with image nginx:1.28 and 2 replicas, serving on port 80
   - api-app with image nginx:1.28 and 2 replicas
3. Expose web-app with a ClusterIP service named web-service on port 80 (targetPort 80)
4. Expose api-app with a ClusterIP service named api-service on port 8080 (targetPort 80)
5. Create an Ingress named app-ingress (ingressClassName nginx) that routes:
   - /    traffic to web-service:80
   - /api traffic to api-service:8080
   - Default backend (no matching path) points to web-service:80
6. Verify the Ingress was created and has an address assigned
7. Test path-based routing by describing the Ingress (check rules) and with curl via the controller NodePort
```

**Validate**
```bash
./lab.sh 19 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-19
kubectl create deployment web-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl create deployment api-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl expose deployment web-app -n exercise-19 --name=web-service --port=80 --target-port=80
kubectl expose deployment api-app -n exercise-19 --name=api-service --port=8080 --target-port=80
kubectl get endpoints -n exercise-19
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: exercise-19
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: web-service
      port:
        number: 80
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
EOF
kubectl get ingress -n exercise-19 -w          # ADDRESS gets filled in
kubectl describe ingress app-ingress -n exercise-19
NP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s -o /dev/null -w "%{http_code}\n" http://node01:$NP/        # 200
```

</details>

## Q20 – Pod Security Standards  (Cluster Architecture | Medium | 15 min)

**Setup**
```bash
./lab.sh 20
```

**Question**
```text
Tasks
1. Create a namespace called exercise-20
2. Label it with Pod Security Standards at restricted level in enforce mode
3. Attempt to run a pod with a privileged container in exercise-20 - it should be rejected
4. Create a second namespace exercise-20-baseline with baseline PSS level (enforce)
5. Run a pod named safe-pod (busybox:1.36, sleep 3600) with runAsNonRoot: true and runAsUser: 1000
   in the baseline namespace - it should succeed
6. Run a pod with privileged: true in the baseline namespace - it should be rejected
7. Create a third namespace exercise-20-audit with restricted level in audit and warn mode only (no enforce)
8. Run a privileged pod named audit-pod (nginx:1.28) in exercise-20-audit - it should succeed,
   but kubectl prints a warning and the violation is recorded in the API audit log
9. Note the warning returned when the pod was created in audit/warn mode
```

**Validate**
```bash
./lab.sh 20 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-20
kubectl label ns exercise-20 pod-security.kubernetes.io/enforce=restricted
kubectl run rogue --image=nginx:1.28 --privileged -n exercise-20          # rejected (forbidden)

kubectl create ns exercise-20-baseline
kubectl label ns exercise-20-baseline pod-security.kubernetes.io/enforce=baseline
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: safe-pod
  namespace: exercise-20-baseline
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl run priv-pod --image=nginx:1.28 --privileged -n exercise-20-baseline   # rejected

kubectl create ns exercise-20-audit
kubectl label ns exercise-20-audit pod-security.kubernetes.io/audit=restricted pod-security.kubernetes.io/warn=restricted
kubectl run audit-pod --image=nginx:1.28 --privileged -n exercise-20-audit    # created, with "Warning: would violate PodSecurity restricted..."
kubectl get ns exercise-20 exercise-20-baseline exercise-20-audit --show-labels
```

</details>

## Q21 – Jobs and CronJobs  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 21
```

**Question**
```text
Work in the default namespace.

Tasks
1. Create a Job named cleanup-job that runs the image busybox:1.37 with command
   echo "Cleanup complete". Run it 3 times (completions=3) serially (parallelism=1)
2. Verify the Job runs to completion (3/3) and check the pod logs
3. Create a CronJob named hourly-backup (image busybox:1.37) that runs every hour (0 * * * *)
   with command: sh -c 'echo "Running backup-script.sh"; date'
   Keep 3 successful job histories (successfulJobsHistoryLimit=3)
4. List CronJobs and check the next scheduled time
5. Manually trigger the CronJob once by creating a Job named manual-backup from it
6. Verify the manual Job ran and logged output
```

**Validate**
```bash
./lab.sh 21 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create job cleanup-job --image=busybox:1.37 --dry-run=client -o yaml -- echo "Cleanup complete" > job.yaml
# add under spec:  completions: 3   parallelism: 1
cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-job
spec:
  completions: 3
  parallelism: 1
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: cleanup
        image: busybox:1.37
        command: ["echo", "Cleanup complete"]
EOF
kubectl get job cleanup-job -w                    # COMPLETIONS 3/3
kubectl logs -l job-name=cleanup-job

cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hourly-backup
spec:
  schedule: "0 * * * *"
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: busybox:1.37
            command: ["sh", "-c", "echo \"Running backup-script.sh\"; date"]
EOF
kubectl get cronjob hourly-backup                 # LAST SCHEDULE / next run
kubectl create job manual-backup --from=cronjob/hourly-backup
kubectl logs job/manual-backup
```

</details>

## Q22 – PriorityClass  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 22
```

**Question**
```text
Work in the default namespace.

Tasks
1. Create a PriorityClass named high-priority with value 1000 and preemptionPolicy PreemptLowerPriority
2. Create a PriorityClass named low-priority with value 10 and preemptionPolicy Never
3. Create a Pod named critical-app using nginx:1.28 and assign it to the high-priority class
4. Create a Pod named background-job using busybox:1.37 running sleep 3600 and assign it to the low-priority class
5. Verify both pods are running. Check their priority values (priority and priorityClassName)
6. Optional: drain a node to trigger preemption and observe which pod gets evicted
```

**Validate**
```bash
./lab.sh 22 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 10
preemptionPolicy: Never
globalDefault: false
---
apiVersion: v1
kind: Pod
metadata:
  name: critical-app
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx:1.28
---
apiVersion: v1
kind: Pod
metadata:
  name: background-job
spec:
  priorityClassName: low-priority
  containers:
  - name: job
    image: busybox:1.37
    command: ["sleep", "3600"]
EOF
kubectl get priorityclass
kubectl get pod -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

</details>

## Q23 – Resource Requests Tuning (Pods Won't Schedule)  (Workloads & Scheduling | Hard | 20 min)

**Setup**
```bash
./lab.sh 23
```

**Question**
```text
The lab setup created namespace exercise-23 and a Deployment named web (3 replicas, nginx:1.27)
whose resource requests are intentionally too high for the cluster.

Tasks
1. Observe pods Pending - they won't all schedule
2. Find out why (describe a Pending pod)
3. Check node capacity and available resources (allocatable minus what is already requested)
4. Calculate correct resource requests so 3 replicas fit, leaving headroom
5. Update the Deployment with the new (lower) requests - keep both cpu and memory requests set
6. Verify all 3 pods schedule and run
7. Document the calculation in /root/exercise-23-calculation.txt
```

**Validate**
```bash
./lab.sh 23 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl get pods -n exercise-23                         # some Pending
kubectl describe pod -n exercise-23 <pending-pod>       # 0/2 nodes available: Insufficient cpu
kubectl describe nodes | grep -A8 -E "Allocatable|Allocated resources"
# Example: node01 allocatable cpu 1000m, already requested 250m -> 750m free
#          3 pods across the nodes with ~20% headroom -> about 150m-200m CPU and 128Mi memory each
kubectl set resources deployment web -n exercise-23 --requests=cpu=150m,memory=128Mi
kubectl rollout status deployment web -n exercise-23
kubectl get pods -n exercise-23 -o wide                 # 3/3 Running
cat <<'EOF' > /root/exercise-23-calculation.txt
node allocatable cpu / memory, minus requests already allocated, divided by 3 replicas,
minus ~20% headroom -> requests cpu=150m memory=128Mi
EOF
```

</details>

## Q24 – PriorityClass and Patch Operations  (Workloads & Scheduling | Medium | 15 min)

**Setup**
```bash
./lab.sh 24
```

**Question**
```text
Tasks
1. Create a namespace called exercise-24
2. Create a PriorityClass with:
   - Name: high-priority
   - Value: 999999
   - Description: "Critical workload"
3. Create a Deployment named critical-app in exercise-24:
   - 1 replica, image busybox:1.36, command sleep 3600
   - Do NOT specify priorityClassName yet
4. Use kubectl patch to add priorityClassName: high-priority to the Deployment
5. Verify the pod has the priority class assigned
6. Create a second, lower-priority Deployment named normal-app (busybox:1.36, sleep 3600, no priority class)
7. Compare the .spec.priority of both pods
```

**Validate**
```bash
./lab.sh 24 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-24
kubectl create priorityclass high-priority --value=999999 --description="Critical workload"
kubectl create deployment critical-app -n exercise-24 --image=busybox:1.36 --replicas=1 -- sleep 3600
kubectl patch deployment critical-app -n exercise-24 -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
# JSON-patch alternative:
# kubectl patch deployment critical-app -n exercise-24 --type=json -p='[{"op":"add","path":"/spec/template/spec/priorityClassName","value":"high-priority"}]'
kubectl rollout status deployment critical-app -n exercise-24
kubectl get pod -n exercise-24 -l app=critical-app -o jsonpath='{.items[0].spec.priorityClassName}'
kubectl create deployment normal-app -n exercise-24 --image=busybox:1.36 -- sleep 3600
kubectl get pod -n exercise-24 -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

</details>

## Q25 – Storage with WaitForFirstConsumer Binding  (Storage | Hard | 20 min)

**Setup**
```bash
./lab.sh 25
```

**Question**
```text
The lab setup created the directory /tmp/k8s-pv on every node.

Tasks
1. Create a namespace called exercise-25
2. Create a StorageClass named local-storage with:
   - Provisioner: kubernetes.io/no-provisioner (local volumes)
   - Binding mode: WaitForFirstConsumer
3. Create a PersistentVolume named local-pv-1 with:
   - Size: 1Gi, AccessMode: ReadWriteOnce, StorageClassName: local-storage
   - Local path: /tmp/k8s-pv, with nodeAffinity to node01
4. Create a PersistentVolumeClaim named local-pvc (1Gi, storageClassName local-storage) in exercise-25
5. Observe: the PVC stays Pending (not Bound) - why?
6. Create a Pod named app-pod (busybox:1.36, sleep 3600) that mounts the PVC at /data
7. Observe: the PVC becomes Bound and the pod schedules on the node where the PV exists
8. Verify persistence by writing /data/test.txt from the pod
```

**Validate**
```bash
./lab.sh 25 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create ns exercise-25
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  local:
    path: /tmp/k8s-pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values: ["node01"]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: exercise-25
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
EOF
kubectl get pvc -n exercise-25      # Pending - WaitForFirstConsumer delays binding until a pod uses it
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: exercise-25
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: local-pvc
EOF
kubectl get pvc -n exercise-25 -w   # Bound
kubectl wait --for=condition=Ready pod/app-pod -n exercise-25
kubectl get pod app-pod -n exercise-25 -o wide    # on node01
kubectl exec app-pod -n exercise-25 -- sh -c 'echo "test data" > /data/test.txt'
kubectl exec app-pod -n exercise-25 -- cat /data/test.txt
```

</details>

## Q26 – CRI-dockerd from the .deb package + switch the kubelet  (Cluster Architecture | Hard | 30 min)

**Setup**
```bash
./lab.sh 26
```

**Question**
```text
Do this on the worker node:  ssh node01
The lab setup downloaded the package to /root/cri-dockerd.deb on node01.

Tasks
1. SSH into node01
2. Install cri-dockerd from /root/cri-dockerd.deb using dpkg
3. Configure the system for cri-dockerd:
   - Enable IP forwarding with sysctl (persistently)
   - Load the kernel modules overlay and br_netfilter
4. Enable and start the cri-docker service and socket
   (the systemd units are called cri-docker.service / cri-docker.socket)
5. Verify the cri-dockerd socket /run/cri-dockerd.sock is available
6. Configure the kubelet on node01 to use cri-dockerd (unix:///run/cri-dockerd.sock)
7. Restart the kubelet and verify node01 is Ready and now reports a docker:// container runtime

./lab.sh 26 cleanup switches node01 back to containerd.
```

**Validate**
```bash
./lab.sh 26 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
ssh node01
dpkg -i /root/cri-dockerd.deb             # needs docker: apt-get install -y docker.io if it complains
modprobe overlay && modprobe br_netfilter
printf "overlay\nbr_netfilter\n" > /etc/modules-load.d/k8s.conf
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/kube.conf
sysctl --system
systemctl enable --now cri-docker.socket cri-docker.service
systemctl status cri-docker --no-pager
ls -la /run/cri-dockerd.sock

# switch the kubelet (kubeadm stores the runtime flag here):
cat /var/lib/kubelet/kubeadm-flags.env
systemctl stop kubelet
crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmp -fa   # stop old containerd pods (avoid port clashes)
sed -i 's#--container-runtime-endpoint=[^ "]*#--container-runtime-endpoint=unix:///run/cri-dockerd.sock#' /var/lib/kubelet/kubeadm-flags.env
cat /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload && systemctl restart kubelet
exit
kubectl get nodes -o wide                  # node01 Ready, CONTAINER-RUNTIME docker://...
# If pods on node01 get no IP: add --network-plugin=cni to ExecStart in
# /lib/systemd/system/cri-docker.service, then daemon-reload + restart cri-docker.
```

</details>

## Q27 – CNI Installation (Calico via the Tigera Operator)  (Services & Networking | Hard | 30 min)

**Setup**
```bash
./lab.sh 27
```

**Question**
```text
The lab setup removed the cluster's CNI. Install Calico v3.30.3 using the Tigera operator.
Manifests:
  https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
  https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/custom-resources.yaml

Tasks
1. Find the cluster pod CIDR (kube-controller-manager --cluster-cidr)
2. Install the Tigera operator from its manifest and wait for the operator deployment
3. Create the Calico Installation custom resource:
   - Set the IP pool CIDR to match the cluster CIDR
   - Use VXLAN (or VXLANCrossSubnet) encapsulation
4. Wait for the calico-system pods to be Ready and the nodes to become Ready
5. Restart pods that were created before the CNI change (e.g. CoreDNS) so they get new IPs
6. Verify pods on different nodes can communicate
7. Test that NetworkPolicy blocking works
```

**Validate**
```bash
./lab.sh 27 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep cluster-cidr
# or: kubectl get cm kubeadm-config -n kube-system -o yaml | grep -i podSubnet
CIDR=<the value above, e.g. 192.168.0.0/16>
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
kubectl wait --for=condition=Available deploy/tigera-operator -n tigera-operator --timeout=300s
cat <<EOF | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: $CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
watch kubectl get tigerastatus                # calico Available True
kubectl get pods -n calico-system
kubectl get nodes                             # Ready
kubectl -n kube-system rollout restart deploy coredns
# test cross-node pod traffic
kubectl run a --image=busybox:1.36 --overrides='{"spec":{"nodeName":"controlplane","tolerations":[{"operator":"Exists"}]}}' -- sleep 3600
kubectl run b --image=busybox:1.36 --overrides='{"spec":{"nodeName":"node01"}}' -- sleep 3600
kubectl exec a -- ping -c2 $(kubectl get pod b -o jsonpath='{.status.podIP}')
# NetworkPolicy test: deny all ingress to b, ping again -> fails
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-b
spec:
  podSelector:
    matchLabels:
      run: b
  policyTypes: [Ingress]
EOF
kubectl exec a -- ping -c2 -W2 $(kubectl get pod b -o jsonpath='{.status.podIP}')   # fails
kubectl delete netpol deny-b; kubectl delete pod a b --now
```

</details>

## Q28 – Complex NetworkPolicy (Multi-Namespace)  (Services & Networking | Hard | 25 min)

**Setup**
```bash
./lab.sh 28
```

**Question**
```text
The lab setup created 3 namespaces with one app each (steps 1-2 are done):
  frontend : Deployment/Service frontend (nginx, port 80),   pod label tier=frontend
  backend  : Deployment/Service backend  (HTTP on 8080),     pod label tier=backend
  database : Deployment/Service database (redis, port 6379), pod label tier=database

Tasks
3. Create NetworkPolicies so that:
   - Everything is denied by default in all three namespaces (ingress AND egress)
   - frontend -> backend is allowed, only on TCP 8080
   - backend -> database is allowed, only on TCP 6379
   - DNS (UDP/TCP 53 to kube-dns in kube-system) is allowed for all pods
4. Explicitly test connectivity to confirm the policies are enforced:
   - frontend CAN reach backend on 8080
   - frontend CANNOT reach database
   - backend CAN reach database on 6379
   - backend CANNOT reach frontend
   - a pod in the default namespace CANNOT reach backend
5. Verify DNS still works from all namespaces
6. If policies don't enforce, verify the CNI supports NetworkPolicy
```

**Validate**
```bash
./lab.sh 28 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
# default deny + DNS in every namespace
for ns in frontend backend database; do
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
EOF
done

cat <<'EOF' | kubectl apply -f -
# frontend may send to backend:8080
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-to-backend
  namespace: frontend
spec:
  podSelector:
    matchLabels: {tier: frontend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend accepts from frontend on 8080
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-from-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: frontend}
      podSelector:
        matchLabels: {tier: frontend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend may send to database:6379
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress-to-database
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: database}
      podSelector:
        matchLabels: {tier: database}
    ports: [{protocol: TCP, port: 6379}]
---
# database accepts from backend on 6379
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ingress-from-backend
  namespace: database
spec:
  podSelector:
    matchLabels: {tier: database}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 6379}]
EOF

# tests
kubectl exec -n frontend deploy/frontend -- curl -s -m3 http://backend.backend.svc.cluster.local:8080          # backend-ok
kubectl exec -n frontend deploy/frontend -- timeout 3 bash -c '</dev/tcp/database.database.svc.cluster.local/6379' || echo blocked
kubectl exec -n backend deploy/backend -- sh -c 'echo PING | nc -w 3 database.database.svc.cluster.local 6379'   # +PONG
kubectl exec -n backend deploy/backend -- wget -q -T 3 -O- http://frontend.frontend.svc.cluster.local || echo blocked
kubectl run outsider --image=busybox:1.36 --rm -it --restart=Never -- wget -q -T 3 -O- http://backend.backend.svc.cluster.local:8080   # blocked
kubectl exec -n backend deploy/backend -- nslookup kubernetes.default.svc.cluster.local                         # DNS works
```

</details>

## Q29 – Troubleshoot Broken Cluster (Incorrect etcd Endpoint)  (Troubleshooting | Hard | 20 min)

**Setup**
```bash
./lab.sh 29
```

**Question**
```text
The cluster is broken: the API server won't start (kubectl does not work).

Tasks
1. Confirm the API server is down
2. Check the kube-apiserver container logs (kubectl can't help - use crictl or /var/log/pods)
3. Find the error: incorrect etcd endpoint IP or port
4. On the control plane node, edit /etc/kubernetes/manifests/kube-apiserver.yaml
5. Correct the etcd endpoint in the --etcd-servers= flag
6. Verify the IP/port matches the client URLs in /etc/kubernetes/manifests/etcd.yaml
7. Save and wait for the API server to restart
8. Verify the cluster is healthy: kubectl get nodes, kubectl get pods -A, API server Running

Do NOT keep backup copies inside /etc/kubernetes/manifests - kubelet runs every file there.
```

**Validate**
```bash
./lab.sh 29 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl get nodes                                           # connection refused
crictl ps -a | grep kube-apiserver                          # Exited / restarting
crictl logs $(crictl ps -a --name kube-apiserver -q | head -1) 2>&1 | tail -20
#   ... dial tcp 10.0.0.5:2379: connect: connection refused / i/o timeout
ls /var/log/pods/ | grep apiserver                          # alternative log location
grep etcd-servers /etc/kubernetes/manifests/kube-apiserver.yaml
grep -E "listen-client-urls|advertise-client-urls" /etc/kubernetes/manifests/etcd.yaml
#   --listen-client-urls=https://127.0.0.1:2379,https://<node-ip>:2379
sed -i 's#--etcd-servers=.*#--etcd-servers=https://127.0.0.1:2379#' /etc/kubernetes/manifests/kube-apiserver.yaml
watch crictl ps --name kube-apiserver                       # Running after ~30-60s
kubectl get nodes
kubectl get pods -A
```

</details>

## Q30 – TLS Configuration Update  (Security | Hard | 20 min)

**Setup**
```bash
./lab.sh 30
```

**Question**
```text
The lab setup created, in namespace exercise-30:
  Deployment tls-web (nginx) - Service tls-web (port 443) - ConfigMap tls-config (nginx.conf) - Secret tls-web-cert
The service currently supports only TLS 1.3.

Tasks
1. Find the TLS setting in the ConfigMap that is mounted into the Deployment
2. Add support for TLS 1.2 (both TLSv1.2 and TLSv1.3 must be enabled)
3. Restart the Deployment so the new configuration is used
4. Verify the service accepts TLS 1.2 connections:
     curl -vk --tlsv1.2 --tls-max 1.2 https://<service-ip>
     or: echo | openssl s_client -connect <service-ip>:443 -tls1_2
5. Verify TLS 1.3 still works:  curl -vk --tlsv1.3 https://<service-ip>
```

**Validate**
```bash
./lab.sh 30 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl get deploy,svc,cm -n exercise-30
kubectl get cm tls-config -n exercise-30 -o yaml | grep ssl_protocols     # TLSv1.3 only
kubectl edit cm tls-config -n exercise-30        # ssl_protocols TLSv1.2 TLSv1.3;
# or in one line:
kubectl get cm tls-config -n exercise-30 -o yaml | sed 's/ssl_protocols TLSv1.3;/ssl_protocols TLSv1.2 TLSv1.3;/' | kubectl replace -f -
kubectl rollout restart deploy tls-web -n exercise-30      # subPath mounts never auto-update
kubectl rollout status deploy tls-web -n exercise-30
IP=$(kubectl get svc tls-web -n exercise-30 -o jsonpath='{.spec.clusterIP}')
curl -sk --tlsv1.2 --tls-max 1.2 https://$IP          # Hello TLS
echo | openssl s_client -connect $IP:443 -tls1_2 2>/dev/null | grep Protocol
curl -sk --tlsv1.3 https://$IP                        # Hello TLS
```

</details>

## Q31 – Argo CD Setup (GitOps Deployment)  (Cluster Architecture | Hard | 25 min)

**Setup**
```bash
./lab.sh 31
```

**Question**
```text
Tasks
1. Install Argo CD v3.1.9 in the cluster:
   - Create the argocd namespace
   - Apply the official manifest (it includes the CRDs - install them once, with server-side apply):
     https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
2. Write an Application manifest and save it to /root/argocd-app.yaml:
   - name my-app, namespace argocd, project default
   - source: https://github.com/argoproj/argocd-example-apps.git, revision HEAD, path guestbook
   - destination: https://kubernetes.default.svc, namespace default
   - automated sync (prune + selfHeal)
3. Verify the Argo CD server is Running
4. Apply the Application manifest
5. Verify the application syncs (status Synced) and the guestbook-ui Deployment appears in default
6. Optional: port-forward to the Argo CD UI and log in as admin
```

**Validate**
```bash
./lab.sh 31 validate
```

<details>
<summary><b>Solution</b> (click to expand)</summary>

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
kubectl wait --for=condition=Available deploy --all -n argocd --timeout=600s
kubectl get pods -n argocd
cat <<'EOF' > /root/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
kubectl apply -f /root/argocd-app.yaml
kubectl get application -n argocd -w          # SYNC STATUS Synced, HEALTH Healthy
kubectl get deploy,svc guestbook-ui
# UI (optional)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d; echo
kubectl port-forward -n argocd svc/argocd-server 8080:443 --address 0.0.0.0
# Exam variant (other labs): helm template ... --set crds.install=false when the CRDs are pre-installed
```

</details>
