# Mock Exam 01 - Question 09 - HPA and Application Scaling  (Workloads & Scheduling | 7 min)
#
# Deployment web-app in namespace production runs 2 replicas. metrics-server is installed.
#
# Tasks
# 1. Create a HorizontalPodAutoscaler named web-app for Deployment web-app that keeps the average
#    CPU utilization at 70%, with at least 2 and at most 10 replicas
# 2. Verify the HPA reads CPU metrics (TARGETS shows a percentage, not <unknown>)
