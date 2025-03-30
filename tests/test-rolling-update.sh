#!/bin/bash

echo "====== Test 3: Rolling Update & Rollback Test ======"

echo "Current deployment status:"
minikube kubectl -- get deployments
minikube kubectl -- get pods

echo "Performing rolling update (simulating new version)..."
# We'll update the CPU resource limit to simulate a new version
minikube kubectl -- patch deployment matrix-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"matrix","resources":{"limits":{"cpu":"600m"}}}]}}}}'

echo "Watching rollout status..."
minikube kubectl -- rollout status deployment/matrix-deployment

echo "Updated deployment configuration:"
minikube kubectl -- describe deployment matrix-deployment | grep -A 5 Resources

echo "Performing rollback..."
minikube kubectl -- rollout undo deployment/matrix-deployment

echo "Watching rollback status..."
minikube kubectl -- rollout status deployment/matrix-deployment

echo "Final deployment configuration after rollback:"
minikube kubectl -- describe deployment matrix-deployment | grep -A 5 Resources

echo "✅ Test complete: Rolling update and rollback demonstrated"