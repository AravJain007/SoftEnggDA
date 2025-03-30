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
minikube ssh "sudo mkdir -p /tmp/chatbot-data && sudo chmod 777 /tmp/chatbot-data"

echo "====== Building Docker image ======"
# Build the image locally
docker build -t chatbot:latest ./streamlit_chatbot

echo "====== Loading Docker image to minikube ======"
# Load the image to minikube
minikube image load chatbot:latest

# If your minikube version doesn't support multi-node image loading, 
# you may need to use an alternate approach like setting up a registry

echo "====== Enable registry addon ======"
minikube addons enable registry

echo "====== Creating Kubernetes Secret ======"
# Read the Groq API key from .env file
if [ -f "./streamlit_chatbot/.env" ]; then
  GROQ_API_KEY=$(grep -oP 'GROQ_API_KEY=\K.*' ./streamlit_chatbot/.env)
  if [ -z "$GROQ_API_KEY" ]; then
    echo "GROQ_API_KEY not found in .env file"
    echo -n "Enter your Groq API key: "
    read -s GROQ_API_KEY
    echo
  fi
else
  echo ".env file not found in streamlit_chatbot folder"
  echo -n "Enter your Groq API key: "
  read -s GROQ_API_KEY
  echo
fi

# Delete existing secret if it exists
minikube kubectl -- delete secret groq-api-key --ignore-not-found

# Create the secret
minikube kubectl -- create secret generic groq-api-key --from-literal=GROQ_API_KEY="$GROQ_API_KEY"

echo "====== Creating Persistent Volume and Claim ======"
minikube kubectl -- apply -f persistent-volume.yaml

echo "====== Deploying the application ======"
minikube kubectl -- apply -f deployment.yaml
minikube kubectl -- apply -f service.yaml

echo "====== Setting up Horizontal Pod Autoscaler ======"
minikube kubectl -- apply -f hpa.yaml

echo "====== Waiting for pods to be ready ======"
minikube kubectl -- wait --for=condition=ready pods --selector=app=chatbot --timeout=120s

echo "====== Deployment Status ======"
minikube kubectl -- get deployments
minikube kubectl -- get pods
minikube kubectl -- get services
minikube kubectl -- get pv
minikube kubectl -- get pvc

echo "====== Getting service URL ======"
minikube service chatbot-service --url

echo "====== Deployment Complete ======"
echo "You can access the application at the URL shown above"