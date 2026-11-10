# CKA Mock Exam 03 (Killer Shell style, 20 questions)

A third timed mock exam modelled on the Killer Shell CKA simulator topics (17 questions + 3 "preview"
questions), rewritten for the Killercoda CKA playground (`controlplane` + `node01`, root).
Run it with `./mock.sh 3 start` (120 min). Answer files go in `/root/mock3/`. Pass mark: 66% (14/20).

Questions 08 and 20 change the cluster heavily, so `start` skips them - run `./mock.sh 3 8` and
`./mock.sh 3 20` when you reach them (do them last; a fresh session afterwards is recommended).

| Q | Topic | Notes |
|---|---|---|
| 01 | Contexts (Cluster access with kubeconfig, 4%) |  |
| 02 | CRD, Helm, cert-manager (Helm / CRDs, 6%) |  |
| 03 | Scale down StatefulSet (Workloads, 2%) |  |
| 04 | Find Pods first to be terminated (Scheduling / QoS, 3%) |  |
| 05 | Kustomize configure HPA Autoscaler (Workloads / Kustomize, 8%) |  |
| 06 | Storage, PV, PVC, Pod volume (Storage, 8%) |  |
| 07 | Node and Pod Resource Usage (Monitoring, 1%) |  |
| 08 | Update Kubernetes Version and join cluster (Cluster Lifecycle, 10%) | on demand |
| 09 | Contact K8s API from inside Pod (Security, 6%) |  |
| 10 | RBAC ServiceAccount Role RoleBinding (Security, 6%) |  |
| 11 | DaemonSet on all Nodes (Scheduling, 4%) |  |
| 12 | Deployment on all Nodes (Scheduling, 6%) |  |
| 13 | Gateway API Ingress (Services & Networking, 7%) |  |
| 14 | Check how long certificates are valid (Cluster Lifecycle, 2%) |  |
| 15 | NetworkPolicy (Services & Networking, 6%) |  |
| 16 | Update CoreDNS Configuration (Services & Networking, 5%) |  |
| 17 | Find Container of Pod and check info (Troubleshooting, 3%) |  |
| 18 | Preview: ETCD Information (Cluster Architecture, 3%) |  |
| 19 | Preview: Kube-Proxy iptables (Services & Networking, 4%) |  |
| 20 | Preview: Change Service CIDR (Services & Networking, 7%) | on demand |

## Question 01 - Contexts  (Cluster access with kubeconfig | 4%)

```text
The kubeconfig file /root/mock3/1/kubeconfig belongs to another cluster (it is not usable
against this one). Use kubectl to extract information from it:

1. Write all context names into /root/mock3/1/contexts, one name per line
2. Write the name of the current context into /root/mock3/1/current-context
3. Write the client certificate of user account-0027@internal, base64-decoded,
   into /root/mock3/1/cert
```

Setup: `./mock.sh 3 1` · Check: `./mock.sh 3 1 validate`

<details><summary>Solution</summary>

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

## Question 02 - CRD, Helm, cert-manager  (Helm / CRDs | 6%)

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

Setup: `./mock.sh 3 2` · Check: `./mock.sh 3 2 validate`

<details><summary>Solution</summary>

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

## Question 03 - Scale down StatefulSet  (Workloads | 2%)

```text
There are two Pods named o3db-* in Namespace project-h800. Management wants them scaled
down to one replica to save resources.
```

Setup: `./mock.sh 3 3` · Check: `./mock.sh 3 3 validate`

<details><summary>Solution</summary>

```bash
kubectl -n project-h800 get pod | grep o3db
kubectl -n project-h800 get deploy,ds,sts | grep o3db       # it is a StatefulSet
kubectl -n project-h800 scale sts o3db --replicas 1
kubectl -n project-h800 get sts o3db                       # READY 1/1
```

</details>

## Question 04 - Find Pods first to be terminated  (Scheduling / QoS | 3%)

```text
Check all Pods in Namespace project-c13 and find those that would most likely be terminated
first if the nodes run out of cpu or memory.

Write their names into /root/mock3/4/pods-terminated-first.txt, one per line.
```

Setup: `./mock.sh 3 4` · Check: `./mock.sh 3 4 validate`

<details><summary>Solution</summary>

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

## Question 05 - Kustomize configure HPA Autoscaler  (Workloads / Kustomize | 8%)

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

Setup: `./mock.sh 3 5` · Check: `./mock.sh 3 5 validate`

<details><summary>Solution</summary>

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

## Question 06 - Storage, PV, PVC, Pod volume  (Storage | 8%)

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

Setup: `./mock.sh 3 6` · Check: `./mock.sh 3 6 validate`

<details><summary>Solution</summary>

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

## Question 07 - Node and Pod Resource Usage  (Monitoring | 1%)

```text
metrics-server is installed. Write two bash scripts that use kubectl:
1. /root/mock3/7/node.sh shows the resource usage of the nodes
2. /root/mock3/7/pod.sh shows the resource usage of Pods and their containers

Use the full command name kubectl, not an alias.
```

Setup: `./mock.sh 3 7` · Check: `./mock.sh 3 7 validate`

<details><summary>Solution</summary>

```bash
kubectl top -h
kubectl top pod -h | grep -A1 containers
echo 'kubectl top node' > /root/mock3/7/node.sh
echo 'kubectl top pod --containers=true' > /root/mock3/7/pod.sh
bash /root/mock3/7/node.sh; bash /root/mock3/7/pod.sh
```

</details>

## Question 08 - Update Kubernetes Version and join cluster  (Cluster Lifecycle | 10%)

```text
A colleague reports that node node01 runs an older Kubernetes version and is not even part
of the cluster yet.

1. Update kubelet and kubectl on node01 to the exact version the control plane runs
2. Add node01 to the cluster using kubeadm

ssh node01 works from controlplane.
This question is set up on demand (./mock.sh 3 8) because it removes node01 from the cluster:
do it near the end of the exam.
```

Setup: `./mock.sh 3 8` · Check: `./mock.sh 3 8 validate`

<details><summary>Solution</summary>

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

## Question 09 - Contact K8s API from inside Pod  (Security | 6%)

```text
ServiceAccount secret-reader exists in Namespace project-swan.
Create Pod api-contact (image nginx:1-alpine) in that Namespace that uses this ServiceAccount.

Exec into the Pod and use curl to query all Secrets (cluster-wide) from the Kubernetes API.
Write the result into /root/mock3/9/result.json on controlplane.
```

Setup: `./mock.sh 3 9` · Check: `./mock.sh 3 9 validate`

<details><summary>Solution</summary>

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

## Question 10 - RBAC ServiceAccount Role RoleBinding  (Security | 6%)

```text
Create ServiceAccount processor in Namespace project-hamster. Create a Role and a RoleBinding,
both named processor, that allow the new ServiceAccount to ONLY create Secrets and ConfigMaps
in that Namespace.
```

Setup: `./mock.sh 3 10` · Check: `./mock.sh 3 10 validate`

<details><summary>Solution</summary>

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

## Question 11 - DaemonSet on all Nodes  (Scheduling | 4%)

```text
In Namespace project-tiger create DaemonSet ds-important, image httpd:2-alpine, with labels
id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462.
Its Pods must request 10 millicore cpu and 10 mebibyte memory and must run on ALL nodes,
control planes included.
```

Setup: `./mock.sh 3 11` · Check: `./mock.sh 3 11 validate`

<details><summary>Solution</summary>

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

## Question 12 - Deployment on all Nodes  (Scheduling | 6%)

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

Setup: `./mock.sh 3 12` · Check: `./mock.sh 3 12 validate`

<details><summary>Solution</summary>

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

## Question 13 - Gateway API Ingress  (Services & Networking | 7%)

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

Setup: `./mock.sh 3 13` · Check: `./mock.sh 3 13 validate`

<details><summary>Solution</summary>

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

## Question 14 - Check how long certificates are valid  (Cluster Lifecycle | 2%)

```text
1. Use openssl (or cfssl) to find out how long the kube-apiserver server certificate is valid.
   Write its expiration date into /root/mock3/14/expiration.
   Then use kubeadm to list the expiration dates and confirm both show the same date.
2. Write the kubeadm command that would renew the kube-apiserver server certificate into
   /root/mock3/14/kubeadm-renew-certs.sh  (do not run it)
```

Setup: `./mock.sh 3 14` · Check: `./mock.sh 3 14 validate`

<details><summary>Solution</summary>

```bash
find /etc/kubernetes/pki | grep apiserver
openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -A2 Validity
openssl x509 -noout -enddate -in /etc/kubernetes/pki/apiserver.crt | cut -d= -f2 > /root/mock3/14/expiration
kubeadm certs check-expiration | grep apiserver          # same date
echo "kubeadm certs renew apiserver" > /root/mock3/14/kubeadm-renew-certs.sh
```

</details>

## Question 15 - NetworkPolicy  (Services & Networking | 6%)

```text
An intruder got into the whole cluster from one hacked backend Pod. To prevent this, create
NetworkPolicy np-backend in Namespace project-snake that allows the backend-* Pods ONLY to:
- connect to db1-* Pods on port 1111
- connect to db2-* Pods on port 2222
Use the app Pod labels in your policy.

All Pods run nginx, so you can test with: kubectl -n project-snake exec POD -- curl -s POD_IP:PORT
After your change, backend -> vault-* on port 3333 must no longer work.
```

Setup: `./mock.sh 3 15` · Check: `./mock.sh 3 15 validate`

<details><summary>Solution</summary>

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

## Question 16 - Update CoreDNS Configuration  (Services & Networking | 5%)

```text
1. Back up the current CoreDNS configuration YAML to /root/mock3/16/coredns_backup.yaml.
   You must be able to restore quickly from it.
2. Change the CoreDNS configuration so that SERVICE.NAMESPACE.custom-domain resolves the same as
   SERVICE.NAMESPACE.cluster.local (in addition to it)

Test from a Pod with image busybox:1 - both must return an IP address:
  nslookup kubernetes.default.svc.cluster.local
  nslookup kubernetes.default.svc.custom-domain
```

Setup: `./mock.sh 3 16` · Check: `./mock.sh 3 16 validate`

<details><summary>Solution</summary>

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

## Question 17 - Find Container of Pod and check info  (Troubleshooting | 3%)

```text
In Namespace project-puma create Pod tigers-reunite (image httpd:2-alpine) with labels
pod=container and container=pod. Find out which node it runs on, ssh to that node and find the
containerd container that belongs to the Pod.

Using crictl:
1. Write the container ID and its info.runtimeType into /root/mock3/17/pod-container.txt
   on controlplane, on one line:  <container-id> <runtimeType>
2. Write the container's logs into /root/mock3/17/pod-container.log on controlplane
```

Setup: `./mock.sh 3 17` · Check: `./mock.sh 3 17 validate`

<details><summary>Solution</summary>

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

## Question 18 - Preview: ETCD Information  (Cluster Architecture | 3%)

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

Setup: `./mock.sh 3 18` · Check: `./mock.sh 3 18 validate`

<details><summary>Solution</summary>

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

## Question 19 - Preview: Kube-Proxy iptables  (Services & Networking | 4%)

```text
Confirm kube-proxy works. In Namespace project-lynx:
1. Create Pod p2-pod with image nginx:1-alpine
2. Create Service p2-service that exposes the Pod inside the cluster on port 3000 -> 80
3. Write the iptables rules of node controlplane that belong to Service p2-service into
   /root/mock3/19/iptables.txt
4. Delete the Service and confirm its iptables rules are gone
```

Setup: `./mock.sh 3 19` · Check: `./mock.sh 3 19 validate`

<details><summary>Solution</summary>

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

## Question 20 - Preview: Change Service CIDR  (Services & Networking | 7%)

```text
1. Create Pod check-ip in Namespace default, image httpd:2-alpine
2. Expose it on port 80 as ClusterIP Service check-ip-service. Note the Service IP
3. Change the Service CIDR of the cluster to 11.96.0.0/12
4. Create a second Service check-ip-service2 for the same Pod - it must get an IP from the
   new range

Set up on demand (./mock.sh 3 20): this restarts the API server and controller manager.
Do it last; a fresh Killercoda session is recommended afterwards.
```

Setup: `./mock.sh 3 20` · Check: `./mock.sh 3 20 validate`

<details><summary>Solution</summary>

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

