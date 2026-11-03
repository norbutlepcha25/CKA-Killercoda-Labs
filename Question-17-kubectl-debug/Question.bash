# Question 17 - kubectl debug: Pod and Node  (Troubleshooting | Medium | 15 min)
#
# Part A: Debug a pod
# 1. Create a namespace called exercise-17
# 2. Create a pod named broken-app with image nginx:1.27
# 3. Attach a debug container to the running pod using kubectl debug:
#    - Image: busybox:1.36
#    - Target the broken-app container to share its process namespace
# 4. From inside the debug container, list the processes (you should see the nginx process)
# 5. Check the filesystem and network from the debug container
# 6. Exit the debug session
#
# Part B: Debug a node
# 7. Run kubectl debug against a node (e.g. node01) to get a shell with host filesystem access
# 8. Use chroot /host to access the real node root
# 9. Check kubelet status from the debug session
# 10. Exit the debug session (leave the node-debugger pod in place for validation)
