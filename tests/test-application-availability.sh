#!/bin/bash

echo "====== Test 1: Application Availability ======"
echo "Getting service information..."
minikube kubectl get services

# Get the service URL
SERVICE_URL=$(minikube service chatbot-service --url)
echo "Service URL: $SERVICE_URL"

echo "Testing application accessibility..."
response=$(curl -s $SERVICE_URL)

if [ -n "$response" ]; then
  echo "✅ Test PASSED: Application is accessible"
  echo "Response received from application"
  echo "$response"
else
  echo "❌ Test FAILED: No response from application"
fi