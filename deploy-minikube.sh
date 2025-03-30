#!/bin/bash

# Exit on any error
set -e

echo "====== Setting up Minikube Cluster ======"
# Check if minikube is already running
if minikube status &>/dev/null; then
  echo "Minikube is already running. Using existing cluster."
else
  # Start Minikube with 3 nodes
  minikube start --nodes=3 --cpus=2 --memory=2048
fi

echo "====== Verifying cluster status ======"
minikube kubectl get nodes

echo "====== Preparing persistent storage directories ======"
# Create directory for persistent storage on the host
minikube ssh "sudo mkdir -p /tmp/matrix-data && sudo chmod 777 /tmp/matrix-data"

echo "====== Building Docker image ======"
# Build the image locally
docker build -t chatbot:latest ./matrix_multiplication

echo "====== Loading Docker image to minikube ======"
# Load the image to minikube
minikube image load chatbot:latest

# If your minikube version doesn't support multi-node image loading, 
# you may need to use an alternate approach like setting up a registry

echo "====== Enable registry addon ======"
minikube addons enable registry

echo "====== Cleaning up existing resources ======"
# Delete existing deployment first to free up the PVC
minikube kubectl -- delete deployment matrix-deployment --ignore-not-found
# Wait a moment for deployment to be deleted
sleep 10
# Delete existing PVC and PV if they exist
minikube kubectl -- delete pvc matrix-pvc --ignore-not-found
minikube kubectl -- delete pv matrix-pv --ignore-not-found

echo "====== Creating Persistent Volume and Claim ======"
minikube kubectl -- apply -f persistent-volume.yaml

echo "====== Deploying the application ======"
minikube kubectl -- apply -f deployment.yaml
minikube kubectl -- apply -f service.yaml

echo "====== Setting up Horizontal Pod Autoscaler ======"
minikube kubectl -- apply -f hpa.yaml

echo "====== Waiting for pods to be ready ======"
minikube kubectl -- wait --for=condition=ready pods --selector=app=matrix --timeout=120s

echo "====== Deployment Status ======"
minikube kubectl -- get deployments
minikube kubectl -- get pods
minikube kubectl -- get services
minikube kubectl -- get pv
minikube kubectl -- get pvc

echo "====== Getting service URL ======"
minikube service matrix-service --url

echo "====== Deployment Complete ======"
echo "You can access the application at the URL shown above"