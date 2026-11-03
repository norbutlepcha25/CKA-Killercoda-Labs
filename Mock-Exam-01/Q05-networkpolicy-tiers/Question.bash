# Mock Exam 01 - Question 05 - Network Policies  (Services & Networking | 10 min)
#
# In namespace shop all pods can currently talk to each other. Pods:
#   frontend (tier=frontend, port 80)   backend (tier=backend, port 3000)
#   database (tier=database, port 5432) outsider (no tier label - use it for testing)
#
# Create NetworkPolicies in namespace shop so that:
# 1. Pods with tier=frontend accept incoming traffic on TCP port 80 only (from anywhere)
# 2. Pods with tier=backend accept incoming traffic only from tier=frontend pods, on TCP port 3000
# 3. Pods with tier=database accept incoming traffic only from tier=backend pods, on TCP port 5432
# Outgoing traffic must not be restricted.
