# Question 02 - Multi-Container Pod / Native Sidecar  (Workloads & Scheduling | Medium | 15 min)
#
# Tasks
# 1. Create a namespace called exercise-02
# 2. Create a pod named logger in namespace exercise-02 with:
#    - An init container (sidecar) named log-agent using busybox:1.36
#      - Set restartPolicy: Always on the init container to make it a native sidecar
#      - Command: tail -F /var/log/app/app.log   (capital F waits for file creation)
#      - Mount a shared volume at /var/log/app
#    - A main container named app using busybox:1.36
#      - Command: write a line to /var/log/app/app.log every 3 seconds
#      - Mount the same shared volume at /var/log/app
#    - Use an emptyDir volume named log-volume
# 3. Verify both containers are running (READY 2/2)
# 4. Check the sidecar's logs to see the streamed output
