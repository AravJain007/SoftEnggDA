#!/bin/bash

echo "====== Test 4: Pod Failure and Self-Healing Test ======"

echo "Current pods:"
minikube kubectl -- get pods

# Get the first pod name
POD_NAME=$(minikube kubectl -- get pods -l app=matrix -o jsonpath='{.items[0].metadata.name}')
echo "Deleting pod: $POD_NAME"

# Delete the pod
minikube kubectl -- delete pod $POD_NAME

echo "Watching for self-healing..."
echo "Press Ctrl+C after you see a new pod created"
minikube kubectl -- get pods -w

echo "✅ Test complete: Check if Kubernetes automatically created a new pod"