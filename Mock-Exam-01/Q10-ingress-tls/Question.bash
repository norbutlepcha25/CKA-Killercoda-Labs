# Mock Exam 01 - Question 10 - Ingress with TLS  (Services & Networking | 8 min)
#
# Service api (namespace default, port 80) must be published through ingress-nginx
# (IngressClass nginx, already installed). The TLS secret api-tls-cert already exists in default.
#
# Tasks
# 1. Create Ingress api-ingress for host api.example.com:
#    - TLS using secret api-tls-cert
#    - path /api (pathType Prefix) -> service api port 80
# 2. Also route /health on host api.example.com to service api port 80. Load balancer health
#    checks call it over plain HTTP, so HTTP requests to /health must be answered directly
#    (not redirected to HTTPS), while HTTP requests to /api are still redirected.
#    Hint: ingress-nginx annotations apply to a whole Ingress object.
# 3. Test with curl against the ingress-nginx NodePorts (use --resolve or a Host header)
