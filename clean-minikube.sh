#!/bin/bash

echo "===== Cleaning up Minikube resources ====="

# Delete the load generator pod if it exists
echo "Deleting load generator pod..."
minikube kubectl -- delete pod load-generator --ignore-not-found=true

# Delete the HPA
echo "Deleting Horizontal Pod Autoscaler..."
minikube kubectl -- delete hpa chatbot-hpa --ignore-not-found=true

# Delete the service
echo "Deleting service..."
minikube kubectl -- delete service chatbot-service --ignore-not-found=true

# Delete the deployment
echo "Deleting deployment..."
minikube kubectl -- delete deployment chatbot-deployment --ignore-not-found=true

# Delete any ConfigMaps or Secrets if they exist
echo "Deleting ConfigMaps and Secrets..."
minikube kubectl -- delete configmap chatbot-config --ignore-not-found=true
minikube kubectl -- delete secret chatbot-secret --ignore-not-found=true

# Check if there are any remaining pods with the chatbot label
echo "Checking for any remaining pods..."
REMAINING_PODS=$(minikube kubectl -- get pods | grep chatbot | wc -l)
if [ "$REMAINING_PODS" -gt 0 ]; then
  echo "Forcing deletion of any remaining pods..."
  minikube kubectl -- delete pods -l app=chatbot --force --grace-period=0
fi

# Verify cleanup
echo "Verifying cleanup..."
echo "Deployments:"
minikube kubectl -- get deployments
echo "Services:"
minikube kubectl -- get services
echo "Pods:"
minikube kubectl -- get pods
echo "HPAs:"
minikube kubectl -- get hpa

# Stop Minikube
minikube stop

# Delete the Minikube cluster
minikube delete

# Start a fresh Minikube cluster
minikube start --nodes 3

# Enable the metrics server for HPA
minikube addons enable metrics-server

echo "===== Cleanup complete ====="
