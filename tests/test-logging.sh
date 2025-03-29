#!/bin/bash

echo "====== Test 6: Logging Test ======"

# Get a pod name
POD_NAME=$(minikube kubectl -- get pods -l app=chatbot -o jsonpath='{.items[0].metadata.name}')
echo "Using pod: $POD_NAME"

echo "Retrieving logs from the pod:"
minikube kubectl -- logs $POD_NAME

echo "✅ Test complete: Check if application logs were displayed above"