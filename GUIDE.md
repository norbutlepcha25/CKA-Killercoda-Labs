# CKA Killercoda Labs – Guide

31 practice labs and 3 timed mock exams for the Killercoda CKA playground. Click **Show solution** to open a solution.

## 1. Setup

1. Open https://killercoda.com/playgrounds/scenario/cka, sign in and click **Start**.
2. In the terminal, clone the repo:

```bash
git clone https://github.com/norbutlepcha25/CKA-Killercoda-Labs.git
cd CKA-Killercoda-Labs
```

3. If a script says *Permission denied*, run once:

```bash
chmod +x lab.sh mock.sh lib/*.sh Question-*/*.sh Question-*/*.bash Mock-Exam-*/*/*.sh Mock-Exam-*/*/*.bash
```

## 2. How to use

**Practice labs**

```bash
./lab.sh list            # all 31 labs
./lab.sh 5               # set up (or reset) lab 5 and print the question
./lab.sh 5 validate      # check your answer
./lab.sh 5 solution      # show the solution
./lab.sh 5 cleanup       # remove the lab
```

**Mock exams** (use a fresh Killercoda session for each exam)

```bash
./mock.sh 1 start        # set up all 15 questions, start the 120-minute clock
./mock.sh 1 time         # time left
./mock.sh 1 4 question   # show question 4 again
./mock.sh 1 11           # exam 1 Q11 only: set it up when you reach it
./mock.sh 1 score        # check everything and print your score (pass = 10/15)
./mock.sh 1 cleanup      # remove everything
```

**Mock exam 3** (Killer Shell style, 20 questions, pass = 14/20)

```bash
./mock.sh 3 start        # sets up 18 questions; Q8 and Q20 are on demand
./mock.sh 3 8            # set up Q8 when you reach it (removes node01 from the cluster)
./mock.sh 3 20           # set up Q20 when you reach it (changes the Service CIDR)
./mock.sh 3 score
```

Answer files that a mock question asks for go in `/root/mock1/`, `/root/mock2/` or `/root/mock3/`.

**Labs that change the cluster:** 09, 18, 26, 27 – do them last or in a fresh session (27 removes the network plugin). 11 and 29 break the cluster on purpose – `./lab.sh 11 cleanup` / `./lab.sh 29 cleanup` repairs it.

## 3. Practice labs

### Lab 1 – Pod Basics  (Workloads & Scheduling | Easy | 10 min)

```bash
./lab.sh 1
```

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

```bash
./lab.sh 1 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 2 – Multi-Container Pod / Native Sidecar  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 2
```

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

```bash
./lab.sh 2 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 3 – ConfigMap & Secret  (Workloads & Scheduling | Easy | 10 min)

```bash
./lab.sh 3
```

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

```bash
./lab.sh 3 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 4 – RBAC  (Cluster Architecture | Medium | 15 min)

```bash
./lab.sh 4
```

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

```bash
./lab.sh 4 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 5 – NetworkPolicy  (Services & Networking | Medium | 20 min)

```bash
./lab.sh 5
```

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

```bash
./lab.sh 5 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 6 – Deployment Rolling Update and Rollback  (Workloads & Scheduling | Easy | 10 min)

```bash
./lab.sh 6
```

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

```bash
./lab.sh 6 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 7 – StatefulSet  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 7
```

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

```bash
./lab.sh 7 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 8 – Node Drain and Cordon  (Cluster Architecture | Easy | 10 min)

```bash
./lab.sh 8
```

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

```bash
./lab.sh 8 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 9 – kubeadm Cluster Upgrade  (Cluster Architecture | Hard | 25 min)

```bash
./lab.sh 9
```

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

```bash
./lab.sh 9 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 10 – Static Pod  (Workloads & Scheduling | Easy | 10 min)

```bash
./lab.sh 10
```

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

```bash
./lab.sh 10 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 11 – Troubleshoot Cluster Components  (Troubleshooting | Hard | 25 min)

```bash
./lab.sh 11
```

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

```bash
./lab.sh 11 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 12 – Storage: PV, PVC and Pod  (Storage | Medium | 15 min)

```bash
./lab.sh 12
```

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

```bash
./lab.sh 12 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 13 – Helm Install, Upgrade and Rollback  (Cluster Architecture | Medium | 15 min)

```bash
./lab.sh 13
```

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

```bash
./lab.sh 13 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 14 – Kustomize: Base and Overlay  (Cluster Architecture | Medium | 15 min)

```bash
./lab.sh 14
```

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

```bash
./lab.sh 14 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 15 – Gateway API: Gateway and HTTPRoute  (Services & Networking | Medium | 20 min)

```bash
./lab.sh 15
```

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

```bash
./lab.sh 15 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 16 – Horizontal Pod Autoscaler  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 16
```

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

```bash
./lab.sh 16 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 17 – kubectl debug: Pod and Node  (Troubleshooting | Medium | 15 min)

```bash
./lab.sh 17
```

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

```bash
./lab.sh 17 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 18 – CRI-dockerd Installation from the release binary  (Cluster Architecture | Medium | 15 min)

```bash
./lab.sh 18
```

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

```bash
./lab.sh 18 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 19 – Classic Ingress  (Services & Networking | Medium | 15 min)

```bash
./lab.sh 19
```

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

```bash
./lab.sh 19 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 20 – Pod Security Standards  (Cluster Architecture | Medium | 15 min)

```bash
./lab.sh 20
```

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

```bash
./lab.sh 20 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 21 – Jobs and CronJobs  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 21
```

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

```bash
./lab.sh 21 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 22 – PriorityClass  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 22
```

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

```bash
./lab.sh 22 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 23 – Resource Requests Tuning (Pods Won't Schedule)  (Workloads & Scheduling | Hard | 20 min)

```bash
./lab.sh 23
```

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

```bash
./lab.sh 23 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 24 – PriorityClass and Patch Operations  (Workloads & Scheduling | Medium | 15 min)

```bash
./lab.sh 24
```

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

```bash
./lab.sh 24 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 25 – Storage with WaitForFirstConsumer Binding  (Storage | Hard | 20 min)

```bash
./lab.sh 25
```

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

```bash
./lab.sh 25 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 26 – CRI-dockerd from the .deb package + switch the kubelet  (Cluster Architecture | Hard | 30 min)

```bash
./lab.sh 26
```

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

```bash
./lab.sh 26 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 27 – CNI Installation (Calico via the Tigera Operator)  (Services & Networking | Hard | 30 min)

```bash
./lab.sh 27
```

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

```bash
./lab.sh 27 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 28 – Complex NetworkPolicy (Multi-Namespace)  (Services & Networking | Hard | 25 min)

```bash
./lab.sh 28
```

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

```bash
./lab.sh 28 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 29 – Troubleshoot Broken Cluster (Incorrect etcd Endpoint)  (Troubleshooting | Hard | 20 min)

```bash
./lab.sh 29
```

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

```bash
./lab.sh 29 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 30 – TLS Configuration Update  (Security | Hard | 20 min)

```bash
./lab.sh 30
```

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

```bash
./lab.sh 30 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Lab 31 – Argo CD Setup (GitOps Deployment)  (Cluster Architecture | Hard | 25 min)

```bash
./lab.sh 31
```

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

```bash
./lab.sh 31 validate
```

<details>
<summary><b>Show solution</b></summary>

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

## 4. Mock Exam 1

Start the whole exam with `./mock.sh 1 start`, check it with `./mock.sh 1 score`.

### Exam 1 · Q1 – Pod Deployment Troubleshooting  (Troubleshooting | 8 min)

```bash
./mock.sh 1 1
```

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

```bash
./mock.sh 1 1 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q2 – RBAC  (Cluster Architecture | 7 min)

```bash
./mock.sh 1 2
```

```text
The user dev-user must be able to list Pods and Deployments in namespace staging,
and nothing in other namespaces.

Tasks
1. Create a Role named staging-reader in namespace staging that allows listing Pods and Deployments
2. Create a RoleBinding named staging-reader-dev-user that grants this Role to the user dev-user
3. Verify with kubectl auth can-i (also check that dev-user can't list pods in namespace default)
```

```bash
./mock.sh 1 2 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl create role staging-reader -n staging --verb=list --resource=pods,deployments
kubectl create rolebinding staging-reader-dev-user -n staging --role=staging-reader --user=dev-user
kubectl auth can-i list pods --as=dev-user -n staging              # yes
kubectl auth can-i list deployments --as=dev-user -n staging       # yes
kubectl auth can-i list pods --as=dev-user -n default              # no
# --resource=deployments resolves to the apps API group, so the rule is correct for Deployments.
```

</details>

### Exam 1 · Q3 – Node Maintenance  (Cluster Architecture | 6 min)

```bash
./mock.sh 1 3
```

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

```bash
./mock.sh 1 3 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q4 – Persistent Volume Configuration  (Storage | 10 min)

```bash
./mock.sh 1 4
```

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

```bash
./mock.sh 1 4 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q5 – Network Policies  (Services & Networking | 10 min)

```bash
./mock.sh 1 5
```

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

```bash
./mock.sh 1 5 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q6 – Helm Chart Deployment  (Cluster Architecture | 8 min)

```bash
./mock.sh 1 6
```

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

```bash
./mock.sh 1 6 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q7 – Container Runtime Configuration  (Cluster Architecture | 8 min)

```bash
./mock.sh 1 7
```

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

```bash
./mock.sh 1 7 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q8 – API Server Audit Logs  (Troubleshooting | 10 min)

```bash
./mock.sh 1 8
```

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

```bash
./mock.sh 1 8 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q9 – HPA and Application Scaling  (Workloads & Scheduling | 7 min)

```bash
./mock.sh 1 9
```

```text
Deployment web-app in namespace production runs 2 replicas. metrics-server is installed.

Tasks
1. Create a HorizontalPodAutoscaler named web-app for Deployment web-app that keeps the average
   CPU utilization at 70%, with at least 2 and at most 10 replicas
2. Verify the HPA reads CPU metrics (TARGETS shows a percentage, not <unknown>)
```

```bash
./mock.sh 1 9 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q10 – Ingress with TLS  (Services & Networking | 8 min)

```bash
./mock.sh 1 10
```

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

```bash
./mock.sh 1 10 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q11 – Cluster Troubleshooting  (Troubleshooting | 12 min)

```bash
./mock.sh 1 11
```

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

```bash
./mock.sh 1 11 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q12 – StatefulSet with Persistent Storage  (Workloads & Storage | 10 min)

```bash
./mock.sh 1 12
```

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

```bash
./mock.sh 1 12 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q13 – Resource Quotas and Limits  (Workloads & Scheduling | 8 min)

```bash
./mock.sh 1 13
```

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

```bash
./mock.sh 1 13 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q14 – Pod Security Standards  (Cluster Architecture | 8 min)

```bash
./mock.sh 1 14
```

```text
Namespace restricted must enforce security policies with Pod Security Admission.

Tasks
1. Enforce the restricted Pod Security Standard on namespace restricted
2. Audit at level baseline in the same namespace
3. Try to create a pod with privileged: true in restricted and verify it is denied.
   Save the error message to /root/mock1/q14-denied.txt
```

```bash
./mock.sh 1 14 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 1 · Q15 – Multi-Container Pod with Sidecar  (Workloads & Scheduling | 8 min)

```bash
./mock.sh 1 15
```

```text
Tasks (namespace default)
Create pod app-with-logger with:
1. Container nginx, image nginx:1.28
2. Container logger, image busybox:1.37, that follows the nginx access log:  tail -F /logs/access.log
3. An emptyDir volume shared by both: mounted at /var/log/nginx in nginx and at /logs in logger
4. Both containers keep running without restarts, and requests to nginx show up in
   kubectl logs app-with-logger -c logger
```

```bash
./mock.sh 1 15 validate
```

<details>
<summary><b>Show solution</b></summary>

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

## 5. Mock Exam 2

Start the whole exam with `./mock.sh 2 start`, check it with `./mock.sh 2 score`.

### Exam 2 · Q1 – Service Discovery and DNS  (Services & Networking | 6 min)

```bash
./mock.sh 2 1
```

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

```bash
./mock.sh 2 1 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q2 – Deployment Rolling Update and Rollback  (Workloads | 8 min)

```bash
./mock.sh 2 2
```

```text
Deployment payment-service in namespace payments was updated to a version that does not work.

Tasks
1. Check the rollout history of payment-service
2. Write the number of the broken revision to /root/mock2/q02-bad-revision.txt
3. Roll back to the last working version (image nginx:1.27)
4. Verify the rollback completed and all 3 replicas are available
```

```bash
./mock.sh 2 2 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q3 – Secrets and Environment Variables  (Workloads | 7 min)

```bash
./mock.sh 2 3
```

```text
Deployment app-deploy in namespace secrets-demo (container app) needs database credentials.

Tasks
1. Create a Secret db-creds in secrets-demo with keys:
     username=dbuser   password=secret123   database=appdb
2. Expose them to the app container as the environment variables DB_USERNAME, DB_PASSWORD and
   DB_DATABASE, taken from the Secret (not as files, and not as plain values in the Deployment)
3. Verify the new pod sees the variables, without the values appearing in the pod logs
```

```bash
./mock.sh 2 3 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q4 – DaemonSet Configuration  (Workloads & Scheduling | 8 min)

```bash
./mock.sh 2 4
```

```text
DaemonSet monitoring-agent in namespace monitoring must run on every node, including the
control plane. Right now the control plane node is missing its agent because of its taint.

Tasks
1. Update the DaemonSet so it tolerates node-role.kubernetes.io/control-plane:NoSchedule
   (keep the image busybox:1.37)
2. Verify one agent pod runs on every node
```

```bash
./mock.sh 2 4 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q5 – API Server Debugging  (Troubleshooting | 9 min)

```bash
./mock.sh 2 5
```

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

```bash
./mock.sh 2 5 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q6 – ConfigMap Updates  (Workloads | 8 min)

```bash
./mock.sh 2 6
```

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

```bash
./mock.sh 2 6 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q7 – PriorityClass and Eviction Order  (Workloads & Scheduling | 9 min)

```bash
./mock.sh 2 7
```

```text
Tasks
1. Create PriorityClass critical-workload with value 1000 and PriorityClass standard-workload
   with value 100. Both use preemptionPolicy PreemptLowerPriority. Neither is the global default.
2. In namespace priority-demo create pods critical-pod-1 and critical-pod-2 (priority class
   critical-workload) and standard-pod (priority class standard-workload), all image nginx:1.27
3. If the node runs out of memory and all three pods use more memory than they request, which
   pod does the kubelet evict first? Write its name to /root/mock2/q07-first-evicted.txt
```

```bash
./mock.sh 2 7 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q8 – Service Types and Exposure  (Services & Networking | 7 min)

```bash
./mock.sh 2 8
```

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

```bash
./mock.sh 2 8 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q9 – CronJob Scheduling  (Workloads | 7 min)

```bash
./mock.sh 2 9
```

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

```bash
./mock.sh 2 9 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q10 – Cluster Certificate Rotation  (Cluster Architecture | 10 min)

```bash
./mock.sh 2 10
```

```text
The control plane certificates expire soon. On the control plane node:

Tasks
1. Save the current expiration overview (kubeadm) to /root/mock2/q10-before.txt
2. Renew all kubeadm-managed certificates
3. Make the control plane components use the new certificates - the API server on port 6443
   must serve the renewed certificate
4. Make sure kubectl still works afterwards
```

```bash
./mock.sh 2 10 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q11 – Pod Disruption Budgets  (Workloads & Scheduling | 8 min)

```bash
./mock.sh 2 11
```

```text
Deployment my-app in namespace pdb-demo runs 10 replicas (label app=my-app). It may never lose
more than 2 pods at once to voluntary disruptions such as node drains.

Tasks
1. Create PodDisruptionBudget app-pdb in pdb-demo that enforces this
2. Test it: drain node01 (ignore DaemonSets, use --timeout=60s) and watch the evictions get blocked
3. Uncordon node01 afterwards and make sure all 10 replicas are available again
```

```bash
./mock.sh 2 11 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q12 – Custom Resource Definitions  (Cluster Architecture | 7 min)

```bash
./mock.sh 2 12
```

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

```bash
./mock.sh 2 12 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q13 – Pod Security Exceptions  (Cluster Architecture | 9 min)

```bash
./mock.sh 2 13
```

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

```bash
./mock.sh 2 13 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q14 – StorageClass and Dynamic Provisioning  (Storage | 8 min)

```bash
./mock.sh 2 14
```

```text
The cluster runs the local-path provisioner (provisioner name rancher.io/local-path).

Tasks
1. Create StorageClass ssd: provisioner rancher.io/local-path, reclaimPolicy Delete,
   volumeBindingMode WaitForFirstConsumer
2. In namespace storage-demo create PVC my-ssd-claim: 20Gi, ReadWriteOnce, storageClassName ssd
3. Create pod app-using-ssd (image nginx:1.27) in storage-demo that mounts the claim at /data
4. Verify a PersistentVolume was created automatically and the claim is Bound
```

```bash
./mock.sh 2 14 validate
```

<details>
<summary><b>Show solution</b></summary>

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

### Exam 2 · Q15 – Namespace Quota and Resource Management  (Workloads & Scheduling | 10 min)

```bash
./mock.sh 2 15
```

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

```bash
./mock.sh 2 15 validate
```

<details>
<summary><b>Show solution</b></summary>

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

## 6. Mock Exam 3 (Killer Shell style)

Start the whole exam with `./mock.sh 3 start`, check it with `./mock.sh 3 score`.
Q8 and Q20 change the cluster heavily, so `start` skips them – set them up when you reach them and do them last.

### Exam 3 · Q1 – Contexts  (Cluster access with kubeconfig | 4%)

```bash
./mock.sh 3 1
```

```text
The kubeconfig file /root/mock3/1/kubeconfig belongs to another cluster (it is not usable
against this one). Use kubectl to extract information from it:

1. Write all context names into /root/mock3/1/contexts, one name per line
2. Write the name of the current context into /root/mock3/1/current-context
3. Write the client certificate of user account-0027@internal, base64-decoded,
   into /root/mock3/1/cert
```

```bash
./mock.sh 3 1 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
K="kubectl --kubeconfig /root/mock3/1/kubeconfig"
$K config get-contexts                                   # overview
$K config get-contexts -o name > /root/mock3/1/contexts
$K config current-context > /root/mock3/1/current-context
# careful: account-0027 is NOT the first entry in .users - select it by name
$K config view --raw -o jsonpath='{.users[?(@.name=="account-0027@internal")].user.client-certificate-data}' \
  | base64 -d > /root/mock3/1/cert
openssl x509 -in /root/mock3/1/cert -noout -subject     # CN = account-0027@internal
```

</details>

### Exam 3 · Q2 – CRD, Helm, cert-manager  (Helm / CRDs | 6%)

```bash
./mock.sh 3 2
```

```text
Install the cert-manager operator with Helm and create a ClusterIssuer for it.
The Helm repo jetstack is already configured.

1. Create Namespace cert-manager
2. Install chart jetstack/cert-manager into that Namespace as release cert-manager,
   with the value crds.enabled=true
3. Edit /root/mock3/2/cluster-issuer.yaml so that spec.selfSigned contains
   crlDistributionPoints: ["http://example.com/crl"]
4. Create the ClusterIssuer from /root/mock3/2/cluster-issuer.yaml

Issuing real certificates is not required.
```

```bash
./mock.sh 3 2 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl create ns cert-manager
helm search repo jetstack
helm -n cert-manager install cert-manager jetstack/cert-manager --set crds.enabled=true
kubectl -n cert-manager rollout status deploy/cert-manager-webhook   # wait for the webhook before step 4
kubectl get crd | grep cert-manager
kubectl explain clusterissuer.spec.selfSigned                       # shows crlDistributionPoints <[]string>
cat > /root/mock3/2/cluster-issuer.yaml <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: course-issuer
spec:
  selfSigned:
    crlDistributionPoints:
    - http://example.com/crl
YAML
kubectl apply -f /root/mock3/2/cluster-issuer.yaml
kubectl get clusterissuer                                            # READY True
```

</details>

### Exam 3 · Q3 – Scale down StatefulSet  (Workloads | 2%)

```bash
./mock.sh 3 3
```

```text
There are two Pods named o3db-* in Namespace project-h800. Management wants them scaled
down to one replica to save resources.
```

```bash
./mock.sh 3 3 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-h800 get pod | grep o3db
kubectl -n project-h800 get deploy,ds,sts | grep o3db       # it is a StatefulSet
kubectl -n project-h800 scale sts o3db --replicas 1
kubectl -n project-h800 get sts o3db                       # READY 1/1
```

</details>

### Exam 3 · Q4 – Find Pods first to be terminated  (Scheduling / QoS | 3%)

```bash
./mock.sh 3 4
```

```text
Check all Pods in Namespace project-c13 and find those that would most likely be terminated
first if the nodes run out of cpu or memory.

Write their names into /root/mock3/4/pods-terminated-first.txt, one per line.
```

```bash
./mock.sh 3 4 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
# Pods without any requests/limits get QoS class BestEffort and are evicted first.
kubectl -n project-c13 get pod -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
kubectl -n project-c13 get pod -o jsonpath='{range .items[*]}{.metadata.name} {.spec.containers[*].resources}{"\n"}{end}'
kubectl -n project-c13 get pod -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' \
  > /root/mock3/4/pods-terminated-first.txt
# Note: c13-3cc-data only has a memory limit -> requests default to the limit, but cpu is unset -> Burstable,
# not BestEffort. c13-2x3-web has requests == limits -> Guaranteed.
```

</details>

### Exam 3 · Q5 – Kustomize configure HPA Autoscaler  (Workloads / Kustomize | 8%)

```bash
./mock.sh 3 5
```

```text
The application api-gateway used an external autoscaler, which is to be replaced by a
HorizontalPodAutoscaler. It is deployed to Namespaces api-gateway-staging and api-gateway-prod with:
  kubectl kustomize /root/mock3/5/api-gateway/staging | kubectl apply -f -
  kubectl kustomize /root/mock3/5/api-gateway/prod    | kubectl apply -f -

Using the Kustomize config in /root/mock3/5/api-gateway:
1. Remove the ConfigMap horizontal-scaling-config completely
2. Add an HPA named api-gateway for Deployment api-gateway: min 2, max 4 replicas,
   scaling at 50% average CPU utilisation
3. In prod the HPA must allow max 6 replicas
4. Apply your changes for staging and prod so the cluster reflects them
```

```bash
./mock.sh 3 5 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
cd /root/mock3/5/api-gateway
kubectl kustomize staging          # see what base + overlay produce
# 1. delete the ConfigMap document from base/api-gateway.yaml AND from the staging/ and prod/ patches
#    (a patch for a resource that no longer exists makes the build fail)
# 2. add to base/api-gateway.yaml (no namespace - the overlays set it):
cat >> base/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
YAML
# 3. add to prod/api-gateway.yaml:
cat >> prod/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6
YAML
kubectl kustomize staging | grep -B5 maxReplicas
kubectl kustomize prod | grep -B5 maxReplicas
# 4. apply - kustomize keeps no state, so the old ConfigMaps must be deleted by hand
kubectl kustomize staging | kubectl apply -f -
kubectl kustomize prod | kubectl apply -f -
kubectl -n api-gateway-staging delete cm horizontal-scaling-config
kubectl -n api-gateway-prod delete cm horizontal-scaling-config
# Optional: remove "replicas: 1" from the Deployment so re-applying does not fight the HPA.
```

</details>

### Exam 3 · Q6 – Storage, PV, PVC, Pod volume  (Storage | 8%)

```bash
./mock.sh 3 6
```

```text
1. Create PersistentVolume safari-pv: capacity 2Gi, accessMode ReadWriteOnce,
   hostPath /Volumes/Data, no storageClassName
2. Create PersistentVolumeClaim safari-pvc in Namespace project-t230: request 2Gi,
   accessMode ReadWriteOnce, no storage class. It must be Bound to safari-pv
3. Create Deployment safari in Namespace project-t230 (image httpd:2-alpine) that mounts
   the volume at /tmp/safari-data

Killercoda hint: if the cluster has a default StorageClass, a PVC without storageClassName
gets the default class added automatically and will not bind to safari-pv. In that case
set  storageClassName: ""  on the PVC (that means "no class").
```

```bash
./mock.sh 3 6 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /Volumes/Data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-t230
spec:
  storageClassName: ""          # only needed when the cluster has a default StorageClass
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
YAML
kubectl -n project-t230 get pv,pvc                 # both Bound
kubectl -n project-t230 create deploy safari --image=httpd:2-alpine --dry-run=client -o yaml > 6_dep.yaml
# add under spec.template.spec:
#   volumes:
#   - name: data
#     persistentVolumeClaim:
#       claimName: safari-pvc
# and under the container:
#   volumeMounts:
#   - name: data
#     mountPath: /tmp/safari-data
kubectl apply -f 6_dep.yaml
kubectl -n project-t230 describe pod -l app=safari | grep -A2 Mounts:
```

</details>

### Exam 3 · Q7 – Node and Pod Resource Usage  (Monitoring | 1%)

```bash
./mock.sh 3 7
```

```text
metrics-server is installed. Write two bash scripts that use kubectl:
1. /root/mock3/7/node.sh shows the resource usage of the nodes
2. /root/mock3/7/pod.sh shows the resource usage of Pods and their containers

Use the full command name kubectl, not an alias.
```

```bash
./mock.sh 3 7 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl top -h
kubectl top pod -h | grep -A1 containers
echo 'kubectl top node' > /root/mock3/7/node.sh
echo 'kubectl top pod --containers=true' > /root/mock3/7/pod.sh
bash /root/mock3/7/node.sh; bash /root/mock3/7/pod.sh
```

</details>

### Exam 3 · Q8 – Update Kubernetes Version and join cluster  (Cluster Lifecycle | 10%) – on demand

```bash
./mock.sh 3 8
```

```text
A colleague reports that node node01 runs an older Kubernetes version and is not even part
of the cluster yet.

1. Update kubelet and kubectl on node01 to the exact version the control plane runs
2. Add node01 to the cluster using kubeadm

ssh node01 works from controlplane.
This question is set up on demand (./mock.sh 3 8) because it removes node01 from the cluster:
do it near the end of the exam.
```

```bash
./mock.sh 3 8 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl get node                                    # control plane version, e.g. v1.34.1
ssh node01
kubelet --version; kubectl version --client; kubeadm version -o short
kubeadm upgrade node                                # fails: node is not part of a cluster -> nothing to upgrade
apt-get update
apt-cache madison kubelet | grep 1.34.1              # use the control plane version
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.34.1-1.1 kubectl=1.34.1-1.1   # (and kubeadm too if it is not on that version)
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet # crash-loops until the node is joined - expected
exit
# on controlplane: create a token and print the join command
kubeadm token create --print-join-command
ssh node01 "kubeadm join <...printed command...>"    # run kubeadm reset -f first if the join complains
kubectl get node                                     # node01 Ready, same version
```

</details>

### Exam 3 · Q9 – Contact K8s API from inside Pod  (Security | 6%)

```bash
./mock.sh 3 9
```

```text
ServiceAccount secret-reader exists in Namespace project-swan.
Create Pod api-contact (image nginx:1-alpine) in that Namespace that uses this ServiceAccount.

Exec into the Pod and use curl to query all Secrets (cluster-wide) from the Kubernetes API.
Write the result into /root/mock3/9/result.json on controlplane.
```

```bash
./mock.sh 3 9 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-swan run api-contact --image=nginx:1-alpine --dry-run=client -o yaml \
  --overrides='{"spec":{"serviceAccountName":"secret-reader"}}' | kubectl apply -f -
kubectl -n project-swan exec -it api-contact -- sh
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  curl --cacert $CACERT https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer $TOKEN" > /tmp/result.json
  # (curl -k ... works too; without the token you are system:anonymous and get 403)
  exit
kubectl -n project-swan exec api-contact -- cat /tmp/result.json > /root/mock3/9/result.json
kubectl auth can-i list secrets --as system:serviceaccount:project-swan:secret-reader   # yes
```

</details>

### Exam 3 · Q10 – RBAC ServiceAccount Role RoleBinding  (Security | 6%)

```bash
./mock.sh 3 10
```

```text
Create ServiceAccount processor in Namespace project-hamster. Create a Role and a RoleBinding,
both named processor, that allow the new ServiceAccount to ONLY create Secrets and ConfigMaps
in that Namespace.
```

```bash
./mock.sh 3 10 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-hamster create sa processor
kubectl -n project-hamster create role processor --verb=create --resource=secret --resource=configmap
kubectl -n project-hamster create rolebinding processor --role processor --serviceaccount project-hamster:processor
A="--as system:serviceaccount:project-hamster:processor"
kubectl -n project-hamster auth can-i create secret $A      # yes
kubectl -n project-hamster auth can-i create configmap $A   # yes
kubectl -n project-hamster auth can-i create pod $A         # no
kubectl -n project-hamster auth can-i get configmap $A      # no
# Valid combos: Role+RoleBinding, ClusterRole+ClusterRoleBinding, ClusterRole+RoleBinding.
# Role+ClusterRoleBinding is not possible.
```

</details>

### Exam 3 · Q11 – DaemonSet on all Nodes  (Scheduling | 4%)

```bash
./mock.sh 3 11
```

```text
In Namespace project-tiger create DaemonSet ds-important, image httpd:2-alpine, with labels
id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462.
Its Pods must request 10 millicore cpu and 10 mebibyte memory and must run on ALL nodes,
control planes included.
```

```bash
./mock.sh 3 11 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-tiger create deployment ds-important --image=httpd:2-alpine --dry-run=client -o yaml > 11.yaml
# edit: kind DaemonSet, remove replicas/strategy/status, set labels, add requests + toleration
cat > 11.yaml <<'YAML'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: ds-important
        image: httpd:2-alpine
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
YAML
kubectl apply -f 11.yaml
kubectl -n project-tiger get ds; kubectl -n project-tiger get pod -l id=ds-important -o wide
```

</details>

### Exam 3 · Q12 – Deployment on all Nodes  (Scheduling | 6%)

```bash
./mock.sh 3 12
```

```text
In Namespace project-jaguar:
- Create Deployment deploy-important with 3 replicas
- The Deployment and its Pods have label id=very-important
- First container container1, image nginx:1-alpine
- Second container container2, image registry.k8s.io/pause:3.10
- Only ONE Pod of this Deployment may ever run on any one node; use
  topologyKey: kubernetes.io/hostname

On Killercoda there is one worker (and a control plane that may be tainted), so some of the
3 Pods stay Pending - that is expected. It mimics a DaemonSet with a fixed replica count.
```

```bash
./mock.sh 3 12 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-jaguar create deployment deploy-important --image=nginx:1-alpine --replicas=3 --dry-run=client -o yaml > 12.yaml
cat > 12.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-jaguar
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      containers:
      - name: container1
        image: nginx:1-alpine
      - name: container2
        image: registry.k8s.io/pause:3.10
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: id
                operator: In
                values: ["very-important"]
            topologyKey: kubernetes.io/hostname
      # alternative to affinity:
      # topologySpreadConstraints:
      # - maxSkew: 1
      #   topologyKey: kubernetes.io/hostname
      #   whenUnsatisfiable: DoNotSchedule
      #   labelSelector:
      #     matchLabels:
      #       id: very-important
YAML
kubectl apply -f 12.yaml
kubectl -n project-jaguar get pod -o wide -l id=very-important   # one per schedulable node, rest Pending
kubectl -n project-jaguar describe pod <pending-pod> | grep FailedScheduling
```

</details>

### Exam 3 · Q13 – Gateway API Ingress  (Services & Networking | 7%)

```bash
./mock.sh 3 13
```

```text
Team r500 wants to replace their Ingress (networking.k8s.io) with a Gateway API
(gateway.networking.k8s.io) solution. The old Ingress is in /root/mock3/13/ingress.yaml.

In Namespace project-r500, using the existing Gateway main:
1. Create HTTPRoute traffic-director that replicates the routes of the old Ingress
2. Extend it with path /auto, which forwards to the mobile backend if the User-Agent header is
   exactly "mobile", and to the desktop backend otherwise

The Gateway is reachable at the URL in /root/mock3/13/gateway-url (r500.gateway is in /etc/hosts).
These must work:
  U=$(cat /root/mock3/13/gateway-url)
  curl $U/desktop        -> Web Desktop App
  curl $U/mobile         -> Web Mobile App
  curl $U/auto -H "User-Agent: mobile"   -> Web Mobile App
  curl $U/auto           -> Web Desktop App
```

```bash
./mock.sh 3 13 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl get gatewayclass; kubectl -n project-r500 get gateway main -o yaml
cat <<'YAML' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  parentRefs:
  - name: main
  hostnames:
  - r500.gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /desktop
    backendRefs:
    - name: web-desktop
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:                 # path AND header in ONE match entry = both must match
        type: PathPrefix
        value: /auto
      headers:
      - type: Exact
        name: user-agent
        value: mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:                 # catch-all for /auto
        type: PathPrefix
        value: /auto
    backendRefs:
    - name: web-desktop
      port: 80
YAML
U=$(cat /root/mock3/13/gateway-url)
curl $U/desktop; curl $U/mobile; curl $U/auto -H "User-Agent: mobile"; curl $U/auto
# "- path: ... - headers: ..." (two list entries) would be OR - wrong here.
```

</details>

### Exam 3 · Q14 – Check how long certificates are valid  (Cluster Lifecycle | 2%)

```bash
./mock.sh 3 14
```

```text
1. Use openssl (or cfssl) to find out how long the kube-apiserver server certificate is valid.
   Write its expiration date into /root/mock3/14/expiration.
   Then use kubeadm to list the expiration dates and confirm both show the same date.
2. Write the kubeadm command that would renew the kube-apiserver server certificate into
   /root/mock3/14/kubeadm-renew-certs.sh  (do not run it)
```

```bash
./mock.sh 3 14 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
find /etc/kubernetes/pki | grep apiserver
openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -A2 Validity
openssl x509 -noout -enddate -in /etc/kubernetes/pki/apiserver.crt | cut -d= -f2 > /root/mock3/14/expiration
kubeadm certs check-expiration | grep apiserver          # same date
echo "kubeadm certs renew apiserver" > /root/mock3/14/kubeadm-renew-certs.sh
```

</details>

### Exam 3 · Q15 – NetworkPolicy  (Services & Networking | 6%)

```bash
./mock.sh 3 15
```

```text
An intruder got into the whole cluster from one hacked backend Pod. To prevent this, create
NetworkPolicy np-backend in Namespace project-snake that allows the backend-* Pods ONLY to:
- connect to db1-* Pods on port 1111
- connect to db2-* Pods on port 2222
Use the app Pod labels in your policy.

All Pods run nginx, so you can test with: kubectl -n project-snake exec POD -- curl -s POD_IP:PORT
After your change, backend -> vault-* on port 3333 must no longer work.
```

```bash
./mock.sh 3 15 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-snake get pod -L app -o wide
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:                     # rule 1: db1 AND port 1111
    - podSelector:
        matchLabels:
          app: db1
    ports:
    - protocol: TCP
      port: 1111
  - to:                     # rule 2: db2 AND port 2222
    - podSelector:
        matchLabels:
          app: db2
    ports:
    - protocol: TCP
      port: 2222
YAML
# WRONG: one rule with both selectors and both ports = (db1 OR db2) AND (1111 OR 2222)
# -> backend could reach db2:1111 and db1:2222.
kubectl -n project-snake exec backend-0 -- curl -s -m3 <db1-ip>:1111   # database one
kubectl -n project-snake exec backend-0 -- curl -s -m3 <vault-ip>:3333 # times out
```

</details>

### Exam 3 · Q16 – Update CoreDNS Configuration  (Services & Networking | 5%)

```bash
./mock.sh 3 16
```

```text
1. Back up the current CoreDNS configuration YAML to /root/mock3/16/coredns_backup.yaml.
   You must be able to restore quickly from it.
2. Change the CoreDNS configuration so that SERVICE.NAMESPACE.custom-domain resolves the same as
   SERVICE.NAMESPACE.cluster.local (in addition to it)

Test from a Pod with image busybox:1 - both must return an IP address:
  nslookup kubernetes.default.svc.cluster.local
  nslookup kubernetes.default.svc.custom-domain
```

```bash
./mock.sh 3 16 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n kube-system get deploy,cm | grep coredns
kubectl -n kube-system get cm coredns -o yaml > /root/mock3/16/coredns_backup.yaml
kubectl -n kube-system edit cm coredns
#   kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {     <- add custom-domain on this line
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system get pod -l k8s-app=kube-dns          # Running = no syntax error
kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
kubectl exec bb -- nslookup kubernetes.default.svc.custom-domain
kubectl exec bb -- nslookup kubernetes.default.svc.cluster.local
# restore if needed:
#   kubectl apply -f /root/mock3/16/coredns_backup.yaml   (or delete + apply) && kubectl -n kube-system rollout restart deploy coredns
```

</details>

### Exam 3 · Q17 – Find Container of Pod and check info  (Troubleshooting | 3%)

```bash
./mock.sh 3 17
```

```text
In Namespace project-puma create Pod tigers-reunite (image httpd:2-alpine) with labels
pod=container and container=pod. Find out which node it runs on, ssh to that node and find the
containerd container that belongs to the Pod.

Using crictl:
1. Write the container ID and its info.runtimeType into /root/mock3/17/pod-container.txt
   on controlplane, on one line:  <container-id> <runtimeType>
2. Write the container's logs into /root/mock3/17/pod-container.log on controlplane
```

```bash
./mock.sh 3 17 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-puma run tigers-reunite --image=httpd:2-alpine --labels "pod=container,container=pod"
kubectl -n project-puma get pod tigers-reunite -o wide          # NODE, e.g. node01
ssh node01
crictl ps | grep tigers-reunite                                 # container ID
crictl inspect <ID> | grep runtimeType                          # io.containerd.runc.v2
exit
echo "<ID> io.containerd.runc.v2" > /root/mock3/17/pod-container.txt
ssh node01 "crictl logs <ID>" > /root/mock3/17/pod-container.log 2>&1   # httpd logs to stderr
```

</details>

### Exam 3 · Q18 – Preview: ETCD Information  (Cluster Architecture | 3%)

```bash
./mock.sh 3 18
```

```text
Find out the following about the etcd that runs on controlplane:
- Server private key location
- Server certificate expiration date
- Is client certificate authentication enabled

Write it into /root/mock3/18/etcd-info.txt in this format:
  Server private key location: <path>
  Server certificate expiration date: <date>
  Is client certificate authentication enabled: <yes|no>
```

```bash
./mock.sh 3 18 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n kube-system get pod | grep etcd                      # static Pod
grep -E -- '--(key-file|cert-file|client-cert-auth)=' /etc/kubernetes/manifests/etcd.yaml
openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt
cat > /root/mock3/18/etcd-info.txt <<TXT
Server private key location: /etc/kubernetes/pki/etcd/server.key
Server certificate expiration date: $(openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt | cut -d= -f2)
Is client certificate authentication enabled: yes
TXT
```

</details>

### Exam 3 · Q19 – Preview: Kube-Proxy iptables  (Services & Networking | 4%)

```bash
./mock.sh 3 19
```

```text
Confirm kube-proxy works. In Namespace project-lynx:
1. Create Pod p2-pod with image nginx:1-alpine
2. Create Service p2-service that exposes the Pod inside the cluster on port 3000 -> 80
3. Write the iptables rules of node controlplane that belong to Service p2-service into
   /root/mock3/19/iptables.txt
4. Delete the Service and confirm its iptables rules are gone
```

```bash
./mock.sh 3 19 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl -n project-lynx run p2-pod --image=nginx:1-alpine
kubectl -n project-lynx expose pod p2-pod --name p2-service --port 3000 --target-port 80
kubectl -n project-lynx get pod,svc,endpointslice
crictl ps | grep kube-proxy; crictl logs <id> 2>&1 | grep -i proxier   # "Using iptables proxy"
iptables-save | grep p2-service
iptables-save | grep p2-service > /root/mock3/19/iptables.txt
kubectl -n project-lynx delete svc p2-service
iptables-save | grep p2-service                                        # nothing
```

</details>

### Exam 3 · Q20 – Preview: Change Service CIDR  (Services & Networking | 7%) – on demand

```bash
./mock.sh 3 20
```

```text
1. Create Pod check-ip in Namespace default, image httpd:2-alpine
2. Expose it on port 80 as ClusterIP Service check-ip-service. Note the Service IP
3. Change the Service CIDR of the cluster to 11.96.0.0/12
4. Create a second Service check-ip-service2 for the same Pod - it must get an IP from the
   new range

Set up on demand (./mock.sh 3 20): this restarts the API server and controller manager.
Do it last; a fresh Killercoda session is recommended afterwards.
```

```bash
./mock.sh 3 20 validate
```

<details>
<summary><b>Show solution</b></summary>

```bash
kubectl run check-ip --image=httpd:2-alpine
kubectl expose pod check-ip --name check-ip-service --port 80
kubectl get svc check-ip-service                       # 10.x IP
vim /etc/kubernetes/manifests/kube-apiserver.yaml      # --service-cluster-ip-range=11.96.0.0/12
watch crictl ps                                        # wait for the new kube-apiserver
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --service-cluster-ip-range=11.96.0.0/12
# Since K8s 1.33 the allocator uses ServiceCIDR objects - add one for the new range:
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: ServiceCIDR
metadata:
  name: svc-cidr-new
spec:
  cidrs:
  - 11.96.0.0/12
YAML
kubectl delete servicecidr kubernetes --wait=false     # stays Terminating while Services still use it
kubectl expose pod check-ip --name check-ip-service2 --port 80
kubectl get svc                                        # check-ip-service2 has an 11.x IP
```

</details>
