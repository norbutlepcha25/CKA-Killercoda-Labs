K="kubectl --kubeconfig /root/mock3/1/kubeconfig"
$K config get-contexts                                   # overview
$K config get-contexts -o name > /root/mock3/1/contexts
$K config current-context > /root/mock3/1/current-context
# careful: account-0027 is NOT the first entry in .users - select it by name
$K config view --raw -o jsonpath='{.users[?(@.name=="account-0027@internal")].user.client-certificate-data}' \
  | base64 -d > /root/mock3/1/cert
openssl x509 -in /root/mock3/1/cert -noout -subject     # CN = account-0027@internal
