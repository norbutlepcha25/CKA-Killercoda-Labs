#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
ensure_helm
C=/root/helm-charts/monitoring
mkdir -p $C/templates
cat > $C/Chart.yaml <<'EOF'
apiVersion: v2
name: monitoring
description: Small monitoring stack used by the CKA mock exam
type: application
version: 0.1.0
appVersion: "1.27"
EOF
cat > $C/values.yaml <<'EOF'
replica_count: 1
storage_size: 10Gi
persistence: false
image: nginx:1.27
EOF
cat > $C/templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replica_count }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: monitoring
        image: {{ .Values.image }}
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF
cat > $C/templates/pvc.yaml <<'EOF'
{{- if .Values.persistence }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Release.Name }}-data
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: {{ .Values.storage_size }}
{{- end }}
EOF
echo "Q06 ready: chart in /root/helm-charts/monitoring ($(helm version --short))."
