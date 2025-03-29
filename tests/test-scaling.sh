#!/bin/bash

echo "====== Flask App Load Test ======"

# Get the service IP and port
SERVICE_NAME="chatbot-service"
CLUSTER_IP=$(minikube kubectl -- get service $SERVICE_NAME -o jsonpath='{.spec.clusterIP}')
SERVICE_PORT=$(minikube kubectl -- get service $SERVICE_NAME -o jsonpath='{.spec.ports[0].port}')
TARGET="http://$CLUSTER_IP:$SERVICE_PORT/"
echo "Target: $TARGET"

# Delete any existing load generator pod
minikube kubectl -- delete pod load-generator --ignore-not-found --force

# Create load generator pod that continuously sends traffic to the Flask app
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
spec:
  containers:
  - name: load-generator
    image: curlimages/curl:latest
    command: ["/bin/sh", "-c"]
    args:
    - |
      echo "Starting load generation on Flask app"
      while true; do
        for i in {1..20}; do
          # Send the request in background with query parameters
          curl -s -o /dev/null "${TARGET}api/load-test?size=1000&iterations=1" &
        done
        wait
        echo "Completed batch, starting next..."
        sleep 1
      done
  resources:
    limits:
      cpu: "1000m"
      memory: "512Mi"
  restartPolicy: Always
EOF

echo "Watching scaling behavior (Ctrl+C to stop)..."
minikube kubectl -- get hpa chatbot-hpa --watch 