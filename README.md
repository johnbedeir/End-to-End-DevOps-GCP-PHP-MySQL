# End-to-End-DevOps-GCP-PHP-MySQL

<img src=cover.png>

This repository contains the source code and configuration files for the "Task Management System" application, a PHP application with MySQL backend. The application is deployed on Google Kubernetes Engine (GKE) and uses Cloud SQL for the database. The repository is organized into multiple directories, each serving a specific purpose in the deployment and management of the application.

## Directory Structure

- `task-management-system/`: Contains the source code of the Task Management System.
- `k8s/`: Kubernetes manifest files for each service.
  - `frontend-service/`
  - `logout-service/`
  - `users-service/`
  - `ingress/`: Manifests for ingress to navigate between service containers.
  - `mysql-job/`: A Kubernetes job to connect to Cloud SQL and create tables for the application.
- `terraform/`: Terraform configuration files for infrastructure as code.
- `.github/`: GitHub workflows for Continuous Integration (CI) and Continuous Deployment (CD).

## Scripts

- `build.sh`: Script to build and deploy the entire project.
- `destroy.sh`: Script to tear down the entire environment.
- `github_secrets.sh`: Script to automate storing secrets in GitHub Secrets.

## Getting Started

### Prerequisites

- Google Cloud SDK
- Docker
- kubectl
- Terraform
- jq
- GitHub CLI (gh)

### Installation

1. **Clone the Repository**

   ```sh
   git clone https://github.com/johnbedeir/End-to-End-DevOps-GCP-Python-MySQL.git
   cd End-to-End-DevOps-GCP-Python-MySQL
   ```

2. **Set Up Google Cloud Credentials**

   Make sure you have the appropriate IAM roles and the service account key file.

3. **Build and Deploy the Project**

   ```sh
   ./build.sh
   ```

### Build Script (`build.sh`)

The `build.sh` script performs the following steps:

1. Authenticate with Google Cloud.
2. Delete existing service account keys.
3. Create new service account keys.
4. Initialize and apply Terraform configurations to set up GKE and other resources.
5. Update kubeconfig to interact with the GKE cluster.
6. Build Docker images for each service and push them to Google Container Registry (GCR).
7. Create necessary Kubernetes secrets.
8. Deploy Kubernetes manifests to the cluster.
9. Output the URLs for various services (application, Prometheus, Grafana, etc.).

### Destroy Script (`destroy.sh`)

The `destroy.sh` script performs the following steps:

1. Authenticate with Google Cloud.
2. Delete Docker images from Google Container Registry.
3. Destroy all GCP resources using Terraform.

### GitHub Secrets Script (`github_secrets.sh`)

The `github_secrets.sh` script performs the following steps:

1. Delete existing service account keys.
2. Create new service account keys.
3. Base64 encode the credentials and environment variables.
4. Store the encoded values as GitHub Secrets.

## GitHub Workflows

- **CI Workflows**: Defined for each service in `.github/workflows/service-ci-workflow`.
- **CD Workflows**: Defined for each service in `.github/workflows/service-cd-workflow`.

## Infrastructure as Code

The `terraform/` directory contains Terraform configuration files to provision the following resources:

- Google Kubernetes Engine (GKE) cluster.
- Google Cloud SQL instance.
- Networking and IAM configurations.

## Deployment

The deployment process is managed using Kubernetes and involves the following steps:

1. Deploy the frontend, logout, and users services.
2. Set up ingress for routing traffic between service containers.
3. Run the `mysql-job` to set up the database schema in Cloud SQL.

## Monitoring and Logging

- Prometheus and Grafana are deployed for monitoring.
- ArgoCD are used for Continuous Deployment.

## Secrets Management

Secrets are managed using Kubernetes secrets and GitHub Secrets. The `github_secrets.sh` script automates the process of storing secrets in GitHub.

## Cleanup

To clean up all resources, run the `destroy.sh` script:

```sh
./destroy.sh
```
