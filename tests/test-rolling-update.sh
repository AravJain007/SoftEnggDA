#!/bin/bash

echo "====== Test 3: Rolling Update & Rollback Test ======"

echo "Current deployment status:"
minikube kubectl -- get deployments
minikube kubectl -- get pods

echo "Performing rolling update (simulating new version)..."
# We'll update the CPU resource limit to simulate a new version
minikube kubectl -- patch deployment chatbot-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"chatbot","resources":{"limits":{"cpu":"600m"}}}]}}}}'

echo "Watching rollout status..."
minikube kubectl -- rollout status deployment/chatbot-deployment

echo "Updated deployment configuration:"
minikube kubectl -- describe deployment chatbot-deployment | grep -A 5 Resources

echo "Performing rollback..."
minikube kubectl -- rollout undo deployment/chatbot-deployment

echo "Watching rollback status..."
minikube kubectl -- rollout status deployment/chatbot-deployment

echo "Final deployment configuration after rollback:"
minikube kubectl -- describe deployment chatbot-deployment | grep -A 5 Resources

echo "✅ Test complete: Rolling update and rollback demonstrated"