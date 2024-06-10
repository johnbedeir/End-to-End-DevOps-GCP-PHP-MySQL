#!/bin/bash

# Variables
project_id="johnydev"
app_repo_name="todo-app-img"
db_repo_name="todo-db-img"
# End Variables

# Get GCP credentials
gcloud iam service-accounts keys create terraform/gcp-credentials.json --iam-account terraform-sa@${project_id}.iam.gserviceaccount.com

#GCR Authentication
echo "--------------------Authenticate Docker with GCR--------------------"
gcloud auth configure-docker

echo "--------------------Enable google apis--------------------"
gcloud services enable cloudresourcemanager.googleapis.com --project ${project_id}

# delete Docker-img from GCR
echo "--------------------Deleting GCR-IMG--------------------"
gcloud container images delete gcr.io/${project_id}/${app_repo_name}:latest --quiet
gcloud container images delete gcr.io/${project_id}/${db_repo_name}:latest --quiet

# delete GCP resources
echo "--------------------Deleting GCP Resources--------------------"
cd terraform && \
terraform destroy -auto-approve
