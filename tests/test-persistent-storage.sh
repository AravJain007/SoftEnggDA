#!/bin/bash

echo "====== Test 5: Persistent Storage Test ======"

# Get a pod name
POD_NAME=$(minikube kubectl -- get pods --selector=app=chatbot -o jsonpath='{.items[0].metadata.name}')
echo "Using pod: $POD_NAME"

# Check if pod was found
if [ -z "$POD_NAME" ]; then
  echo "Error: No pod with label app=chatbot was found!"
  exit 1
fi

# Get service URL
SERVICE_URL=$(minikube service chatbot-service --url)
echo "Service URL: $SERVICE_URL"

echo "Checking if test file exists in the persistent volume..."
INITIAL_RESPONSE=$(curl -s $SERVICE_URL/check-persistence)
echo "Initial file content: $INITIAL_RESPONSE"

echo "Deleting the pod to test persistence..."
minikube kubectl -- delete pod $POD_NAME

echo "Waiting for a new pod to be created..."
sleep 30  # Give enough time for the new pod to be ready

# Get the new pod name
NEW_POD_NAME=$(minikube kubectl -- get pods --selector=app=chatbot -o jsonpath='{.items[0].metadata.name}')
echo "New pod created: $NEW_POD_NAME"

# Check if new pod was found
if [ -z "$NEW_POD_NAME" ]; then
  echo "Error: No new pod was created with label app=chatbot!"
  exit 1
fi

# Wait for the pod to be ready
echo "Waiting for the new pod to be ready..."
minikube kubectl -- wait --for=condition=ready pod $NEW_POD_NAME --timeout=60s

echo "Checking if the test file still exists in the new pod:"
AFTER_RESPONSE=$(curl -s $SERVICE_URL/check-persistence)
echo "File content after pod restart: $AFTER_RESPONSE"

# Check if the data persisted
if [ "$AFTER_RESPONSE" == "$INITIAL_RESPONSE" ]; then
  echo "✅ Test PASSED: Data persisted across pod restarts!"
else
  echo "❌ Test FAILED: Data did not persist across pod restarts"
  echo "Original content: $INITIAL_RESPONSE"
  echo "Current content: $AFTER_RESPONSE"
fi