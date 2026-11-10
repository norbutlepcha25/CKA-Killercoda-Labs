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
