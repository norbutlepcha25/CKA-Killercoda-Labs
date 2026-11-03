#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/mock2
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.example.com
spec:
  group: example.com
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames: ["db"]
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - name: Engine
      type: string
      jsonPath: .spec.engine
    - name: Version
      type: string
      jsonPath: .spec.version
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["engine"]
            properties:
              engine:
                type: string
                enum: ["postgres", "mysql"]
              version:
                type: string
              storage:
                type: string
EOF
kubectl wait --for=condition=Established crd/databases.example.com --timeout=60s >/dev/null
kubectl create ns crd-demo >/dev/null
cat <<'EOF' | kubectl apply -f - >/dev/null
apiVersion: example.com/v1
kind: Database
metadata:
  name: old-db
  namespace: crd-demo
spec:
  engine: mysql
  version: "5.7"
  storage: 20Gi
EOF
echo "Q12 ready."
