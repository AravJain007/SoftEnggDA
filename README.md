# Matrix Multiplication Application on Kubernetes

A containerized Python application for high-performance matrix multiplication with Kubernetes deployment on Minikube, featuring auto-scaling, persistent storage, and comprehensive testing.

## Project Overview

This project demonstrates deploying a CPU-intensive matrix multiplication application on Kubernetes with:

- Containerization using Docker
- Kubernetes deployment with 3 replicas
- Horizontal Pod Autoscaling (HPA) based on CPU utilization
- Persistent storage for data retention
- Rolling updates and rollbacks
- Self-healing capabilities
- Resource management and optimization

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Project Structure

```
.
├── matrix_app/            # Application directory
│   ├── app.py             # Python application for matrix multiplication
│   ├── Dockerfile         # Docker configuration
│   ├── requirements.txt   # Python dependencies
│   └── static/            # Static files for web UI
├── kubernetes/            # Kubernetes configuration files
│   ├── deployment.yaml    # Deployment configuration
│   ├── service.yaml       # Service configuration
│   ├── hpa.yaml           # Horizontal Pod Autoscaler configuration
│   └── persistent-volume.yaml  # Persistent storage configuration
├── deploy-minikube.sh     # Deployment script
├── clean-minikube.sh      # Cleanup script
└── tests/                 # Test scripts
    ├── test-application-availability.sh
    ├── test-scaling.sh
    ├── test-rolling-update.sh
    ├── test-self-healing.sh
    ├── test-persistent-storage.sh
    └── test-logging.sh
```

## About the Application

The matrix multiplication application provides a REST API for performing intensive matrix operations:

- Generates random matrices of configurable sizes
- Performs matrix multiplication operations
- Measures and reports execution time
- Supports configurable iteration counts for benchmarking
- Includes a simple web UI for interacting with the service

## Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### Step 2: Make Scripts Executable

```bash
chmod +x *.sh
chmod +x tests/*.sh
```

### Step 3: Deploy the Application

```bash
./deploy-minikube.sh
```

This script will:

- Start a Minikube cluster with 3 nodes
- Build the Docker image for the matrix multiplication application
- Load the image into Minikube
- Set up persistent storage
- Deploy the application with 3 replicas
- Configure the Horizontal Pod Autoscaler
- Display the service URL

### Step 4: Access the Application

The deployment script will output a URL that you can use to access the application. The application provides:

- **Web Interface**: Access via browser at the provided URL
- **API Endpoints**:
  - `/api/matrix-multiply` - POST endpoint for matrix multiplication with configurable size and iterations
    ```json
    {
      "matrix_size": 1000,
      "iterations": 3
    }
    ```
  - `/api/load-test?size=1000&iterations=3` - GET endpoint for load testing
  - `/check-persistence` - Endpoint to verify persistent storage functionality

## Testing

The project includes comprehensive test scripts to verify different aspects of the Kubernetes deployment:

### 1. Application Availability Test

```bash
./tests/test-application-availability.sh
```

Verifies that the application is accessible and responding to requests.

### 2. Auto-scaling Test

```bash
./tests/test-scaling.sh
```

Tests the Horizontal Pod Autoscaler by generating load on the application with large matrix multiplication operations, triggering Kubernetes to automatically scale the number of pods based on CPU utilization.

### 3. Rolling Update Test

```bash
./tests/test-rolling-update.sh
```

Demonstrates how Kubernetes performs rolling updates to minimize downtime when deploying new versions of the application.

### 4. Self-healing Test

```bash
./tests/test-self-healing.sh
```

Shows how Kubernetes automatically replaces failed pods to maintain the desired replica count, ensuring application availability even when pods crash or become unresponsive.

### 5. Persistent Storage Test

```bash
./tests/test-persistent-storage.sh
```

Verifies that data persists across pod restarts and reschedules using Kubernetes persistent volumes.

### 6. Logging Test

```bash
./tests/test-logging.sh
```

Demonstrates how to access and analyze logs from the application pods for monitoring and troubleshooting.

## Performance Testing

You can run performance tests on the application by sending requests with different matrix sizes:

```bash
# Simple test with 1000x1000 matrices, 3 iterations
curl -X POST http://<service-url>/api/matrix-multiply \
  -H "Content-Type: application/json" \
  -d '{"matrix_size": 1000, "iterations": 3}'

# High load test for testing auto-scaling
curl "http://<service-url>/api/load-test?size=2000&iterations=5"
```

## Cleaning Up

To remove all resources and stop the Minikube cluster:

```bash
./clean-minikube.sh
```

## Kubernetes Configuration Details

### Deployment (deployment.yaml)

- Deploys 3 replicas of the application
- Configures resource requests and limits:
  - CPU request: 100m (0.1 CPU core)
  - CPU limit: 500m (0.5 CPU core)
- Mounts persistent storage for data retention
- Uses the Container Registry addon in Minikube

### Service (service.yaml)

- Exposes the application on NodePort 30001
- Makes the application accessible outside the cluster

### Horizontal Pod Autoscaler (hpa.yaml)

- Scales between 2-5 pods based on CPU utilization
- Target CPU utilization set to 50%
- Allows the application to handle varying workloads efficiently

### Persistent Volume (persistent-volume.yaml)

- Creates storage that persists beyond pod lifecycles
- Ensures data is retained even when pods are rescheduled

## Implementation Notes

- The application is containerized using Docker for consistent deployment across environments
- Resource limits prevent any single pod from consuming excessive resources
- The application automatically scales up during high load periods and down during low demand
- Persistent storage ensures data survivability across pod restarts and failures
- The testing suite provides comprehensive validation of Kubernetes features

## Troubleshooting

If you encounter issues during deployment:

1. Check Minikube status:

   ```bash
   minikube status
   ```

2. View running pods:

   ```bash
   kubectl get pods
   ```

3. Check pod logs:

   ```bash
   kubectl logs <pod-name>
   ```

4. Verify services:

   ```bash
   kubectl get services
   ```

5. Inspect HPA status:
   ```bash
   kubectl get hpa
   kubectl describe hpa chatbot-hpa
   ```
