#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
D=/root/mock3/1; mkdir -p $D /root/.cka-lab; T=$(mktemp -d)
openssl req -x509 -newkey rsa:2048 -nodes -keyout $T/ca.key -out $T/ca.crt -days 365 -subj "/CN=kubernetes" >/dev/null 2>&1
for u in admin account-0027 account-0028; do
  openssl req -newkey rsa:2048 -nodes -keyout $T/$u.key -out $T/$u.csr -subj "/CN=$u@internal" >/dev/null 2>&1
  openssl x509 -req -in $T/$u.csr -CA $T/ca.crt -CAkey $T/ca.key -CAcreateserial -out $T/$u.crt -days 300 >/dev/null 2>&1
done
b(){ base64 -w0 < "$1"; }
cat > $D/kubeconfig <<YAML
apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    certificate-authority-data: $(b $T/ca.crt)
    server: https://10.30.110.30:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: admin@internal
  name: cluster-admin
- context:
    cluster: kubernetes
    user: account-0027@internal
  name: cluster-w100
- context:
    cluster: kubernetes
    user: account-0028@internal
  name: cluster-w200
current-context: cluster-w200
users:
- name: account-0028@internal
  user:
    client-certificate-data: $(b $T/account-0028.crt)
    client-key-data: $(b $T/account-0028.key)
- name: account-0027@internal
  user:
    client-certificate-data: $(b $T/account-0027.crt)
    client-key-data: $(b $T/account-0027.key)
- name: admin@internal
  user:
    client-certificate-data: $(b $T/admin.crt)
    client-key-data: $(b $T/admin.key)
YAML
cp $T/account-0027.crt /root/.cka-lab/mock3-q1-expected.crt
rm -rf $T
echo "Q01 ready: /root/mock3/1/kubeconfig"
