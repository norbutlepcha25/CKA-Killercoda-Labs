#!/bin/bash
# Shared helpers used by every validate.sh / LabSetUp.bash / cleanup.sh
PASS=0; FAIL=0; WARN=0
GREEN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[0;33m'; NC='\033[0m'

pass(){ echo -e "  ${GREEN}[PASS]${NC} $*"; PASS=$((PASS+1)); }
fail(){ echo -e "  ${RED}[FAIL]${NC} $*"; FAIL=$((FAIL+1)); }
warn(){ echo -e "  ${YEL}[WARN]${NC} $*"; WARN=$((WARN+1)); }

# check "description" <command...>   -> PASS if the command succeeds
check(){ local d="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$d"; else fail "$d"; fi; }
# eq "description" "<actual>" "<expected>"
eq(){ if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (got '$2', expected '$3')"; fi; }
# nonempty "description" "<actual>"
nonempty(){ if [ -n "$2" ]; then pass "$1"; else fail "$1 (empty)"; fi; }

# jp <jsonpath> <kubectl get args...>   -> prints value or nothing
jp(){ local p="$1"; shift; kubectl get "$@" -o jsonpath="$p" 2>/dev/null; }

summary(){
  echo
  echo "Result: $PASS passed, $FAIL failed, $WARN warnings"
  if [ "$FAIL" -eq 0 ]; then echo -e "${GREEN}SUCCESS - all checks passed${NC}"; exit 0
  else echo -e "${RED}NOT YET - fix the failed checks and run validate again${NC}"; exit 1; fi
}

# Node helpers (Killercoda CKA playground: controlplane + node01)
cp_node(){ local n; n=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); echo "${n:-controlplane}"; }
worker_node(){ local n; n=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); echo "${n:-node01}"; }

# on_node <node> "<command>"  -> runs locally if it is this host, otherwise over ssh
on_node(){
  local n="$1"; shift
  if [ -z "$n" ] || [ "$n" = "$(hostname)" ] || [ "$n" = "$(hostname -s)" ]; then bash -c "$*"
  else ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o LogLevel=ERROR "$n" "$*"; fi
}

# del_ns <ns...>  -> delete namespaces and wait until they are gone
del_ns(){
  local ns i left
  for ns in "$@"; do
    kubectl get ns "$ns" >/dev/null 2>&1 || continue
    kubectl delete pods --all -n "$ns" --force --grace-period=0 >/dev/null 2>&1
    kubectl delete ns "$ns" --wait=false >/dev/null 2>&1
  done
  for i in $(seq 1 90); do
    left=0; for ns in "$@"; do kubectl get ns "$ns" >/dev/null 2>&1 && left=1; done
    [ "$left" = 0 ] && return 0
    sleep 2
  done
  echo "  (namespace(s) $* still terminating - continuing anyway)"
}

# wait_ready <namespace> <selector> [timeout]
wait_ready(){ kubectl wait --for=condition=Ready pod -n "$1" -l "$2" --timeout="${3:-180s}" >/dev/null 2>&1; }

banner(){ echo; echo "==================================================================="; echo " $*"; echo "==================================================================="; }

# ---------------------------------------------------------------------------
# Helpers used by the mock exams (Mock-Exam-0N/)
# ---------------------------------------------------------------------------
ensure_helm(){
  command -v helm >/dev/null && return 0
  echo "Installing helm ..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null
}

ensure_metrics_server(){
  if ! kubectl get deploy metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Installing metrics-server ..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null
    kubectl patch deployment metrics-server -n kube-system --type=json \
      -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null
  fi
  kubectl rollout status deployment metrics-server -n kube-system --timeout=180s >/dev/null
}

ensure_ingress_nginx(){
  local IV=controller-v1.13.3
  if ! kubectl get deploy ingress-nginx-controller -n ingress-nginx >/dev/null 2>&1; then
    echo "Installing ingress-nginx ($IV, NodePort) ..."
    kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/$IV/deploy/static/provider/baremetal/deploy.yaml" >/dev/null
  fi
  kubectl wait --for=condition=Complete job -n ingress-nginx --all --timeout=180s >/dev/null 2>&1
  kubectl wait --for=condition=Available deploy/ingress-nginx-controller -n ingress-nginx --timeout=300s >/dev/null
  # the admission webhook answers a little after the Deployment is Available
  for i in $(seq 1 30); do
    printf 'apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:\n  name: webhook-probe\n  namespace: default\nspec:\n  ingressClassName: nginx\n  defaultBackend:\n    service:\n      name: none\n      port:\n        number: 80\n' \
      | kubectl apply --dry-run=server -f - >/dev/null 2>&1 && break
    sleep 5
  done
}

# ensure_local_path -> a working rancher.io/local-path provisioner and a StorageClass named local-path
ensure_local_path(){
  if ! kubectl get sc -o jsonpath='{.items[*].provisioner}' 2>/dev/null | grep -qw rancher.io/local-path; then
    echo "Installing local-path-provisioner v0.0.32 ..."
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml >/dev/null
    kubectl -n local-path-storage rollout status deploy/local-path-provisioner --timeout=180s >/dev/null
  fi
  kubectl get sc local-path >/dev/null 2>&1 || cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML
}

# wait_apiserver [seconds] -> call right after changing kube-apiserver.yaml: waits until kubelet has
# replaced the running kube-apiserver container and the new one answers
wait_apiserver(){
  local i old new
  old=$(crictl ps --name kube-apiserver --state running -q 2>/dev/null | head -1)
  for i in $(seq 1 30); do
    new=$(crictl ps --name kube-apiserver --state running -q 2>/dev/null | head -1)
    [ -n "$old" ] && [ "$new" != "$old" ] && break
    sleep 3
  done
  sleep 5
  for i in $(seq 1 $(( ${1:-180} / 3 ))); do kubectl get --raw=/readyz >/dev/null 2>&1 && return 0; sleep 3; done
  return 1
}

# A clean copy of kube-apiserver.yaml shared by the labs that change it (mock 1 Q08, mock 2 Q05).
APISERVER_MANIFEST=/etc/kubernetes/manifests/kube-apiserver.yaml
APISERVER_PRISTINE=/root/.cka-lab/kube-apiserver.pristine.yaml
# apiserver_reset -> put kube-apiserver.yaml back to the clean copy (saving it first if needed)
apiserver_reset(){
  mkdir -p /root/.cka-lab
  if [ -f $APISERVER_PRISTINE ]; then
    if ! cmp -s $APISERVER_PRISTINE $APISERVER_MANIFEST; then
      cp $APISERVER_PRISTINE $APISERVER_MANIFEST
      echo "Restored the original kube-apiserver manifest - waiting for the API server ..."
      wait_apiserver 240
    fi
  elif grep -q -- '--audit-' $APISERVER_MANIFEST; then
    echo "kube-apiserver.yaml already has --audit-* flags and there is no clean copy to go back to."
    echo "Remove the audit flags/volumes from $APISERVER_MANIFEST (or use a fresh Killercoda session) and run the setup again."
    return 1
  else
    cp $APISERVER_MANIFEST $APISERVER_PRISTINE
  fi
}

# try_pod <ns> <name> <req-cpu> <req-mem> <lim-cpu> <lim-mem> -> succeeds if the API server would admit the pod
try_pod(){
  kubectl run "$2" -n "$1" --image=nginx:1.27 --restart=Never --dry-run=server -o name \
    --overrides="{\"spec\":{\"containers\":[{\"name\":\"$2\",\"image\":\"nginx:1.27\",\"resources\":{\"requests\":{\"cpu\":\"$3\",\"memory\":\"$4\"},\"limits\":{\"cpu\":\"$5\",\"memory\":\"$6\"}}}]}}" >/dev/null 2>&1
}

# oneof "description" "<actual>" <allowed...>
oneof(){ local d="$1" a="$2" v; shift 2; for v in "$@"; do [ "$a" = "$v" ] && { pass "$d"; return; }; done; fail "$d (got '$a', expected one of: $*)"; }

# filecontent <path> -> file content with surrounding whitespace removed
filecontent(){ [ -f "$1" ] && tr -d '\r' < "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed '/^$/d'; }

# ensure_envoy_gateway -> Envoy Gateway v1.5.4 + GatewayClass "eg" whose proxies use a NodePort Service
# (same install as practice lab Q15; used by mock exam 3 Q13)
ensure_envoy_gateway(){
  local EGV=v1.5.4
  if ! kubectl get deploy envoy-gateway -n envoy-gateway-system >/dev/null 2>&1; then
    echo "Installing Envoy Gateway $EGV (Gateway API CRDs + controller) ..."
    kubectl apply --server-side --force-conflicts -f "https://github.com/envoyproxy/gateway/releases/download/$EGV/install.yaml" >/dev/null
  fi
  kubectl wait --for=condition=Available deploy/envoy-gateway -n envoy-gateway-system --timeout=300s >/dev/null
  cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: nodeport-proxy
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService:
        type: NodePort
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: nodeport-proxy
    namespace: envoy-gateway-system
YAML
  kubectl wait --for=condition=Accepted gatewayclass/eg --timeout=120s >/dev/null 2>&1
}

# same_time "description" "<date string>" "<date string>" -> PASS if both parse to times <= 60s apart
same_time(){
  local a b
  a=$(date -d "$2" +%s 2>/dev/null); b=$(date -d "$3" +%s 2>/dev/null)
  if [ -n "$a" ] && [ -n "$b" ] && [ $(( a > b ? a - b : b - a )) -le 60 ]; then pass "$1"
  else fail "$1 (got '$2', expected '$3')"; fi
}

# in_cidr12 <ip> <first-octet> -> succeeds if ip is inside <first-octet>.96.0.0/12
in_cidr12(){ local a b c d; IFS=. read -r a b c d <<< "$1"; [ "$a" = "$2" ] && [ -n "$b" ] && [ "$b" -ge 96 ] && [ "$b" -le 111 ]; }
