# CKA Killercoda Labs (31 questions + 3 mock exams)

Hands-on labs built from the 31 exercises and the two mock exams in
[norbutlepcha25/CKA-Certified-Kubernetes-Administrator](https://github.com/norbutlepcha25/CKA-Certified-Kubernetes-Administrator).
Each question has a lab setup, the task text, solution notes and an automatic checker.
They are written for the Killercoda CKA playground (`controlplane` + `node01`, logged in as root).

- `lab.sh` runs the 31 practice labs (below).
- `mock.sh` runs the three timed mock exams (see [Mock exams](#mock-exams), `CKA-Mock-Exams.md` and `CKA-Mock-Exam-03.md`).

## Get the labs into Killercoda

Killercoda has no file upload, so clone this repo in the Killercoda terminal:

```bash
# in the Killercoda terminal (https://killercoda.com/playgrounds/scenario/cka)
git clone https://github.com/norbutlepcha25/CKA-Killercoda-Labs.git
cd CKA-Killercoda-Labs
chmod +x lab.sh mock.sh lib/*.sh Question-*/*.sh Question-*/LabSetUp.bash Mock-Exam-*/*/*.sh Mock-Exam-*/*/LabSetUp.bash
./lab.sh list
./mock.sh list
```

## Use

```bash
./lab.sh 5              # reset + set up question 5, then print the question
./lab.sh 5 question     # print the question again
./lab.sh 5 validate     # check your answer ([PASS]/[FAIL] per check)
./lab.sh 5 solution     # show the solution notes
./lab.sh 5 cleanup      # remove what the lab and your answer created
```

Running a lab's setup again always resets it, so you can retry a question as often as you like.
You can also run the files directly, e.g. `bash Question-05-networkpolicy/LabSetUp.bash`.

## Folder layout

```
lab.sh                      runner
CKA-Labs-Questions.md       all 31 questions with setup/validate commands and hidden solutions
lib/common.sh               shared helpers (pass/fail, node helpers, ssh to node01)
lib/cri-reset.sh            puts node01 back on containerd (used by Q18 and Q26)
Question-NN-topic/
  LabSetUp.bash             resets the lab, installs prerequisites, breaks things for troubleshooting labs
  Question.bash             the task
  SolutionNotes.bash        a worked solution
  validate.sh               automatic checks
  cleanup.sh                removes / restores everything for this question
```

## What the setups install or change

| Q | Setup does | Session impact |
|---|---|---|
| 09 | Adds the apt repo for the next Kubernetes minor version on both nodes, writes the target to `/root/upgrade-target.txt` | Upgrade can't be undone - fresh session to repeat |
| 11 | Stops + disables kubelet on node01, breaks CoreDNS (typo + 0 replicas) | `cleanup` restores both |
| 13 | Installs Helm if missing | - |
| 15 | Installs Envoy Gateway v1.5.4 + GatewayClass `eg` (NodePort) | Stays installed |
| 16 | Installs metrics-server if missing | Stays installed |
| 18 | Resets any cri-dockerd install on node01 | Changes node01 runtime setup - fresh session recommended |
| 19 | Installs ingress-nginx controller-v1.13.3 (NodePort), IngressClass `nginx` | Stays installed |
| 23 | Creates a Deployment whose requests are too big for the nodes | - |
| 25 | Creates `/tmp/k8s-pv` on every node | - |
| 26 | Downloads `/root/cri-dockerd.deb` to node01, backs up the kubelet flags | `cleanup` switches node01 back to containerd |
| 27 | **Removes the cluster CNI** (asks for `yes`; `CKA_LAB_YES=1` skips the prompt) | Fresh session, do it on its own |
| 28 | Creates namespaces frontend/backend/database with an app in each | - |
| 29 | Points kube-apiserver at a wrong etcd endpoint (backup in `/root/.cka-lab/`) | `cleanup` restores the manifest |
| 30 | Creates an nginx Deployment that only allows TLS 1.3 | - |
| 31 | Removes any previous Argo CD install | Argo CD needs ~1.5 GB RAM |

Tip: run the destructive labs (09, 18, 26, 27) at the end of a session, or each in a fresh one.

## Changes from the original exercises

The original text is kept where possible. These changes make every lab runnable and checkable:

- Named things the exercise left open (e.g. Deployment `drain-test` in Q08, Job `manual-backup` in Q21,
  `/root/kustomize-lab` in Q14, Service `tls-web` in Q30, `/root/argocd-app.yaml` in Q31).
- Q11, Q23, Q29, Q30: the setup creates the broken or starting state that the exercise describes.
- Q20: the audit namespace uses audit + warn only. The original also set `enforce=restricted`,
  which would reject the privileged pod the task says should succeed.
- Q24: the busybox Deployments run `sleep 3600`. Plain busybox exits at once and crash-loops.
- Q26: the systemd units are `cri-docker.service` / `cri-docker.socket` (not `cri-dockerd`), and the
  kubelet switch uses `/var/lib/kubelet/kubeadm-flags.env`.
- Q27: the Installation resource is fixed. The original had a stray `pointerSize: Felix` line.
- Q28: the solution uses default-deny plus explicit egress. The original's DNS-only egress policy
  blocked frontend -> backend.
- Images and versions are pinned to ones that exist today (Calico v3.30.3, Argo CD v3.1.9, Envoy Gateway v1.5.4).
- Q13: Bitnami moved most free images in 2025. If the pods sit in ImagePullBackOff, the solution notes
  give the `bitnamilegacy` override. The Helm checks still pass.

## Mock exams

The two mock exams from the source repo (`mock-exams/MOCK-EXAM-01.md`, `MOCK-EXAM-02.md`) are now labs too:
15 questions each, 120 minutes, pass mark 66% (10/15). `CKA-Mock-Exams.md` has every question with
its setup and validate commands and a collapsible solution.

```bash
./mock.sh list
./mock.sh 1 start            # set up all 15 questions and start a 120-minute clock (./mock.sh 1 start 90 for 90 min)
./mock.sh 1 questions        # print all questions again
./mock.sh 1 time             # time left
./mock.sh 1 score            # check every question -> "Score: 12/15 (80%)"
./mock.sh 1 solutions        # all solutions (after the exam)
./mock.sh 1 cleanup          # remove everything exam 1 created

./mock.sh 2 7                # set up / reset only exam 2, question 7 and print it
./mock.sh 2 7 validate       # check only that question ([PASS]/[FAIL] per check)
./mock.sh 2 7 solution
./mock.sh 2 7 cleanup
```

Answer files that a question asks for go in `/root/mock1/` or `/root/mock2/`.
Use a fresh Killercoda session for each exam: some questions change the control plane.

| Exam · Q | What the setup does / session impact |
|---|---|
| 1 · Q03 | Your answer leaves node01 cordoned - later pods only land on the control plane until you uncordon |
| 1 · Q06 | Installs Helm if missing, writes a chart to `/root/helm-charts/monitoring` |
| 1 · Q07 | Installs docker.io + cri-dockerd v0.3.20 on node01 (1-2 min). Your answer switches node01 to Docker; `./mock.sh 1 7 cleanup` switches it back |
| 1 · Q08 | Keeps a clean copy of the kube-apiserver manifest in `/root/.cka-lab/kube-apiserver.pristine.yaml`; your answer restarts the API server. `cleanup` restores the clean copy |
| 1 · Q09 | Installs metrics-server if missing |
| 1 · Q10 | Installs ingress-nginx controller-v1.13.3 (NodePort) if missing |
| 1 · Q11 | **Breaks the kube-scheduler.** `start` skips it - run `./mock.sh 1 11` when you reach it. `cleanup` restores the manifest |
| 1 · Q12, 2 · Q14 | Make sure a `rancher.io/local-path` provisioner and StorageClass `local-path` exist (installs local-path-provisioner v0.0.32 if needed) |
| 2 · Q04 | Adds the standard kubeadm taint `node-role.kubernetes.io/control-plane:NoSchedule` to the control plane if it is missing; `cleanup` removes it again |
| 2 · Q05 | **Enables API server audit logging** (restarts the API server, ~1-2 min); `cleanup` restores the clean manifest copy (shared with 1 · Q08) |
| 2 · Q10 | Your answer renews the control plane certificates and restarts the static pods (can't be undone, harmless) |
| 2 · Q11 | Your answer drains node01; the question ends with uncordoning it |

### Mock exam 3 (Killer Shell style)

`Mock-Exam-03/` has 20 questions modelled on the Killer Shell CKA simulator topics (17 + 3 "preview"
questions): kubeconfig contexts, Helm + cert-manager CRDs, StatefulSet scaling, QoS classes,
Kustomize + HPA, PV/PVC, `kubectl top`, kubeadm upgrade + join, API access from a Pod, RBAC,
DaemonSet / one-Pod-per-node scheduling, Gateway API HTTPRoute, certificate expiry, NetworkPolicy,
CoreDNS, crictl, etcd info, kube-proxy iptables and changing the Service CIDR. The tasks are rewritten
for Killercoda; `CKA-Mock-Exam-03.md` lists them all with collapsible solutions.

```bash
./mock.sh 3 start            # 18 questions set up; Q08 and Q20 are on demand
./mock.sh 3 score            # pass mark 66% (14/20)
```

Answer files go in `/root/mock3/`.

| Exam · Q | What the setup does / session impact |
|---|---|
| 3 · Q02 | Installs Helm if missing and adds the jetstack repo; your answer installs cert-manager (`cleanup` removes it and its CRDs) |
| 3 · Q05, Q07 | Install metrics-server if missing |
| 3 · Q08 | **Removes node01 from the cluster** (kubeadm reset) and downgrades its kubelet/kubectl one minor version. On demand: `./mock.sh 3 8`. `cleanup` re-joins node01 on the control plane version |
| 3 · Q13 | Installs Envoy Gateway v1.5.4 + GatewayClass `eg` (NodePort, same as practice lab 15), adds `r500.gateway` to `/etc/hosts` |
| 3 · Q15 | Needs a CNI that enforces NetworkPolicy (the Killercoda playground does) |
| 3 · Q16 | Saves the original Corefile; `cleanup` restores it |
| 3 · Q20 | **Changes the Service CIDR** (restarts kube-apiserver and kube-controller-manager). On demand: `./mock.sh 3 20`. `cleanup` restores both manifests; use a fresh session afterwards |

Kubernetes 1.33+ is needed for Q20 (ServiceCIDR API). The checkers have not yet been run end to end on
Killercoda - report a wrong [FAIL] as an issue.

### Changes from the original mock exams

The original questions are kept where they work. Where a question or its published solution was wrong
or could not be checked, the lab changes it:

- Every question names its objects, namespaces and answer files so it can be checked automatically.
- Exam 1 Q03: the original asked to drain the node without evicting a database pod, and the solution used
  `--force` (which deletes that pod). The lab has a standalone `database` pod with emptyDir data; the
  answer is to cordon and drain only the web pods (`--pod-selector`).
- Exam 1 Q04: the solution used a GKE provisioner and `kubectl create pvc` (no such command) and `kubectl set volume` (an OpenShift `oc` command). The lab uses a
  static hostPath PV with StorageClass `fast-ssd` (`kubernetes.io/no-provisioner`).
- Exam 1 Q05: the solution's NetworkPolicies had `protocol` directly under the ingress rule (invalid) and the
  frontend policy had no `ports` list. Fixed.
- Exam 1 Q07: the solution edited `/etc/kubernetes/kubelet.conf` (the kubelet's kubeconfig). The runtime flag
  lives in `/var/lib/kubelet/kubeadm-flags.env` (or `containerRuntimeEndpoint` in `/var/lib/kubelet/config.yaml`).
- Exam 1 Q08: the solution parsed the audit log as a JSON array (`jq '.[]'`); it is JSON lines. The lab adds a
  client that reads ConfigMaps so there is something to find.
- Exam 1 Q10: "health endpoint should not require TLS" contradicted the solution. The lab makes it concrete:
  HTTP `/health` must not be redirected, solved with a second Ingress with `ssl-redirect: "false"`.
- Exam 1 Q11: the lab breaks the scheduler (wrong kubeconfig path) so there is something to troubleshoot.
- Exam 1 Q13: a 2 CPU / 2Gi pod fits a 4 CPU / 8Gi quota, so it would not be rejected. The test pod is 6 CPU / 4Gi.
  `kubectl run --requests` was removed in 1.24; the solution uses `--overrides`.
- Exam 1 Q14: the expected error mentioned PodSecurityPolicy (removed in 1.25) and said restricted needs a
  read-only root filesystem (it doesn't). Fixed.
- Exam 1 Q15: `tail -f` exits if the log does not exist yet; the lab uses `tail -F`.
- Exam 2 Q01: the solution used `wget` in an nginx image (not installed). The lab uses busybox.
- Exam 2 Q04: `datadog/agent:latest` is a >1 GB image that also needs an API key; the lab uses busybox.
- Exam 2 Q05: "provide the commands" became concrete tasks (save logs, port, readyz, find the noisy client
  in the audit log, stop it). kube-apiserver is a static pod, so there is no systemd unit to `journalctl`.
- Exam 2 Q06: the lab shows both cases - a volume mount updates without a restart, an env var needs a rollout restart.
- Exam 2 Q07: the solution set `globalDefault: true` (changes every new pod in the cluster). The lab keeps
  both classes non-default; the eviction-order part is answered in a file, with the kubelet's real ranking explained.
- Exam 2 Q08: `nodePort: 8080` is outside the NodePort range (30000-32767) and would be rejected. The lab uses
  service port 8080, targetPort 3000, nodePort 30080.
- Exam 2 Q09: `backup-tool:latest` doesn't exist; busybox is used. "Start it again" became a manual Job from the CronJob.
- Exam 2 Q10: `systemctl restart kubelet` and deleting the mirror pod do not restart a static pod's container.
  The solution moves the manifests out and back, then checks the certificate served on :6443.
- Exam 2 Q13: Pod Security Admission has no per-pod exemption label (`pod-security.kubernetes.io/exempt` on a
  pod does nothing). The lab runs the root pod in a separate namespace that enforces baseline, and the
  solution explains the AdmissionConfiguration exemptions.
- Exam 2 Q14: uses the local-path provisioner instead of a GKE CSI driver.
- Exam 2 Q15: `kubectl run --requests` replaced with `--overrides`; the test pod exceeds the LimitRange max.

## Test status

Tested on a 2-node kind cluster (Kubernetes v1.35.1, kindnet CNI, which enforces NetworkPolicy) set up like the
Killercoda playground: logged in as root on the control plane, `ssh` to the worker, systemd, crictl.
For each lab the setup ran, then the solution notes, then the checker. For the mock exams each checker was also
run before the answer to make sure it fails.

| Labs | Result |
|---|---|
| Practice labs 01-08, 10-17, 19-25, 28-30 | All checks pass, including the running-pod checks: pods Running, curl through ingress-nginx and the Gateway, DNS lookups, TLS 1.2/1.3 connections, NetworkPolicy blocking |
| Practice lab 11 | Both breaks (kubelet stopped on the worker, CoreDNS typo + 0 replicas) are created and the fixes pass |
| Practice lab 29 | etcd endpoint break and fix pass |
| Mock exam 1, Q1-Q6, Q8-Q15 | Pass with the solution, fail without it. Run through `./mock.sh 1 start` + `score` too |
| Mock exam 2, all 15 | Pass with the solution, fail without it. `./mock.sh 2 start` -> solutions -> `./mock.sh 2 score` gave 15/15 |

Not tested (they can't run on the arm64 kind test cluster or need a real kubeadm node):
practice labs 09 (kubeadm upgrade), 18 and 26 (cri-dockerd), 27 (CNI install), 31 (Argo CD), and mock exam 1 Q07
(cri-dockerd). Run those on Killercoda first and report anything that fails.

Fixes made to the practice labs during this test:

- Q19 and the mock exams' ingress setup: wait until the ingress-nginx admission webhook answers. Right after
  install the Deployment is Available but the webhook still refuses connections, so the first Ingress failed.
- Q24 checker: a pod of the old ReplicaSet that is still terminating could be checked instead of the new one.
- Q12, Q25 solutions: wait for the pod to be Ready before `kubectl exec`.

