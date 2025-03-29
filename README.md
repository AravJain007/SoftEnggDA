# Matrix Multiplication Kubernetes Deployment

A containerized Python application for matrix multiplication with Kubernetes deployment configuration for Minikube, featuring auto-scaling, persistent storage, and comprehensive testing.

## Project Overview

This project demonstrates deploying a Python matrix multiplication application on Kubernetes with:

- Containerization using Docker
- Kubernetes deployment with 3 replicas
- Horizontal Pod Autoscaling (HPA) based on CPU utilization
- Persistent storage for data retention
- Rolling updates and rollbacks
- Self-healing capabilities
- Kubernetes secrets for sensitive information

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Groq API Key](https://console.groq.com/)

## Project Structure

```
.
├── streamlit_chatbot/       # Application directory
│   ├── app.py               # Python application for matrix multiplication
│   ├── Dockerfile           # Docker configuration
│   ├── requirements.txt     # Python dependencies
│   └── static/              # Static files for web UI
├── deployment.yaml          # Kubernetes deployment configuration
├── service.yaml             # Kubernetes service configuration
├── hpa.yaml                 # Horizontal Pod Autoscaler configuration
├── persistent-volume.yaml   # Persistent storage configuration
├── deploy-minikube.sh       # Deployment script
├── clean-minikube.sh        # Cleanup script
└── tests/                   # Test scripts
    ├── test-application-availability.sh
    ├── test-scaling.sh
    ├── test-rolling-update.sh
    ├── test-self-helping.sh
    ├── test-persistent-storage.sh
    └── test-logging.sh
```

## Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### Step 2: Configure the Groq API Key

Create a `.env` file in the `streamlit_chatbot` directory:

```bash
echo "GROQ_API_KEY=your_api_key_here" > streamlit_chatbot/.env
```

### Step 3: Make Scripts Executable

```bash
chmod +x *.sh
chmod +x tests/*.sh
```

### Step 4: Deploy the Application

```bash
./deploy-minikube.sh
```

This script will:

- Start a Minikube cluster with 3 nodes
- Build and load the Docker image
- Create necessary Kubernetes secrets
- Set up persistent storage
- Deploy the application with replicas
- Configure the Horizontal Pod Autoscaler
- Display the service URL

### Step 5: Access the Application

The deployment script will output a URL that you can use to access the application. The application provides endpoints for performing matrix multiplication operations:

- `/api/matrix-multiply` - POST endpoint for matrix multiplication with configurable size and iterations
- `/api/load-test` - GET endpoint for load testing with parameters for matrix size and iterations
- `/check-persistence` - Endpoint to verify persistent storage functionality

## Testing

The project includes comprehensive test scripts in the `tests/` directory to verify different aspects of the Kubernetes deployment:

### 1. Application Availability Test

```bash
./tests/test-application-availability.sh
```

Verifies that the application is accessible and responding to requests.

### 2. Auto-scaling Test

```bash
./tests/test-scaling.sh
```

Tests the Horizontal Pod Autoscaler by generating load on the application and observing how Kubernetes automatically scales the number of pods.

### 3. Rolling Update Test

```bash
./tests/test-rolling-update.sh
```

Demonstrates how Kubernetes performs rolling updates to minimize downtime when deploying new versions of the application.

### 4. Self-healing Test

```bash
./tests/test-self-helping.sh
```

Shows how Kubernetes automatically replaces failed pods to maintain the desired replica count.

### 5. Persistent Storage Test

```bash
./tests/test-persistent-storage.sh
```

Verifies that data persists across pod restarts and reschedules.

### 6. Logging Test

```bash
./tests/test-logging.sh
```

Demonstrates how to access logs from the application pods.

## Cleaning Up

To remove all resources and stop the Minikube cluster:

```bash
./clean-minikube.sh
```

## Kubernetes Configuration Details

### Deployment (deployment.yaml)

- Deploys 3 replicas of the application
- Configures resource requests and limits
- Mounts persistent storage
- References the Groq API key from Kubernetes secrets

### Service (service.yaml)

- Exposes the application on NodePort 30001
- Makes the application accessible outside the cluster

### Horizontal Pod Autoscaler (hpa.yaml)

- Scales between 2-5 pods based on CPU utilization
- Target CPU utilization set to 50%

### Persistent Volume (persistent-volume.yaml)

- Creates storage that persists beyond pod lifecycles
- Ensures data is retained even when pods are rescheduled

## Implementation Notes

- The application is containerized using Docker for consistent deployment
- Kubernetes secrets store sensitive information securely
- Resource limits prevent any single pod from consuming excessive resources
- The application can automatically scale up during high load periods and down during low demand
- Persistent storage ensures data survivability across pod restarts and failures
