#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
B=/root/mock3/5/api-gateway; mkdir -p $B/base $B/staging $B/prod
cat > $B/base/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - api-gateway.yaml
YAML
cat > $B/base/api-gateway.yaml <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-gateway
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  horizontal-scaling: "70"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      id: api-gateway
  template:
    metadata:
      labels:
        id: api-gateway
    spec:
      serviceAccountName: api-gateway
      containers:
      - image: httpd:2-alpine
        name: httpd
        resources:
          requests:
            cpu: 10m
            memory: 20Mi
YAML
for env in staging prod; do
  case $env in staging) V=60;; prod) V=80;; esac
  cat > $B/$env/kustomization.yaml <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base
patches:
  - path: api-gateway.yaml
transformers:
  - |-
    apiVersion: builtin
    kind: NamespaceTransformer
    metadata:
      name: notImportantHere
      namespace: api-gateway-$env
YAML
  cat > $B/$env/api-gateway.yaml <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  horizontal-scaling: "$V"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  labels:
    env: $env
YAML
  kubectl create ns api-gateway-$env >/dev/null
  kubectl kustomize $B/$env | kubectl apply -f - >/dev/null
done
ensure_metrics_server
echo "Q05 ready: /root/mock3/5/api-gateway deployed to api-gateway-staging and api-gateway-prod"
