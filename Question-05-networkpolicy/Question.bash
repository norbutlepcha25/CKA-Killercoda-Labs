# Question 05 - NetworkPolicy  (Services & Networking | Medium | 20 min)
#
# Tasks
# 1. Create a namespace called exercise-05
# 2. Deploy two pods:
#    - frontend with image nginx:1.27 and label role=frontend
#    - backend  with image nginx:1.27 and label role=backend
# 3. Verify that frontend can reach backend on port 80 (should work before any policy)
# 4. Create a NetworkPolicy named backend-policy that:
#    - Applies to pods with label role=backend
#    - Allows ingress only from pods with label role=frontend on port 80
#    - Allows egress to DNS (UDP port 53) - if you skip this, DNS breaks
# 5. Verify that frontend can still reach backend
# 6. Create a third pod attacker (image nginx:1.27, label role=attacker) and verify it cannot reach backend
