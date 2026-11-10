# Mock Exam 03 - Question 12 - Deployment on all Nodes  (Scheduling | 6%)
#
# In Namespace project-jaguar:
# - Create Deployment deploy-important with 3 replicas
# - The Deployment and its Pods have label id=very-important
# - First container container1, image nginx:1-alpine
# - Second container container2, image registry.k8s.io/pause:3.10
# - Only ONE Pod of this Deployment may ever run on any one node; use
#   topologyKey: kubernetes.io/hostname
#
# On Killercoda there is one worker (and a control plane that may be tainted), so some of the
# 3 Pods stay Pending - that is expected. It mimics a DaemonSet with a fixed replica count.
