#!/bin/bash

# Variables
# GCP
project_id="johnydev"
service_account_email="terraform-sa@${project_id}.iam.gserviceaccount.com"
key_ids=$(gcloud iam service-accounts keys list --iam-account=${service_account_email} --format="value(name)")
filename="gcp-credentials.json"
# Docker images
app_path="task-management-system"
frontend_dockerfile="frontend.Dockerfile"
users_dockerfile="users.Dockerfile"
logout_dockerfile="logout.Dockerfile"
sql_job_dockerfile="mysql.Dockerfile"
frontend_repo_name="tms-frontend-img" 
users_repo_name="tms-users-img"
logout_repo_name="tms-logout-img"
sql_job_repo_name="tms-mysql-job-img"
frontend_image_name="gcr.io/${project_id}/${frontend_repo_name}:latest"
users_image_name="gcr.io/${project_id}/${users_repo_name}:latest"
logout_image_name="gcr.io/${project_id}/${logout_repo_name}:latest"
sql_job_image_name="gcr.io/${project_id}/${sql_job_repo_name}:latest"
# Database
dbsecretname="db-password"
db_generated_password="$(gcloud secrets versions access latest --secret=cluster-1-cloudsql-secrets | jq -r '.password')"
dbsecretusername="db-username"
cloudsql_endpoint="sql-endpoint"
#  K8s
app_namespace="tms-app"
monitoring_namespace="monitoring"
alertmanager_svc="kube-prometheus-stack-alertmanager"
prometheus_svc="kube-prometheus-stack-prometheus"
grafana_svc="kube-prometheus-stack-grafana"
argo_svc="argocd-server"
argo_namespace="argocd"
ingress_svc="nginx-ingress-ingress-nginx-controller"
ingress_namespace="ingress-nginx"
# Terraform
cd terraform
cloudsql_public_ip="$(terraform output -raw cloudsql_public_ip)"
cloudsecretname="$(terraform output -raw cloud_sql_name)"
zone="$(terraform output -raw cluster_zone)"
cluster_name="$(terraform output -raw cluster_name)"
dbendpoint="$(terraform output -raw cloudsql_public_ip)"
dbusername="$(terraform output -raw db_username)"
cd ..
# End Variables

# update helm repos
helm repo update

# Google cloud authentication
echo "--------------------GCP Login--------------------"
gcloud auth login

# Check if there are any keys to delete
if [ -z "$key_ids" ]; then
    echo "No keys found for service account: $service_account_email"
    exit 0
fi

# Loop through each key ID and delete the key
for key_id in $key_ids; do
    echo "Deleting key $key_id for service account: $service_account_email"
    gcloud iam service-accounts keys delete ${key_id} --iam-account=${service_account_email} --quiet
done

# Get GCP credentials
echo "--------------------Get Credentials--------------------"
gcloud iam service-accounts keys create terraform/${filename} --iam-account ${service_account_email}

# Build the infrastructure
echo "--------------------Creating GKE--------------------"
echo "--------------------Creating GCR--------------------"
echo "--------------------Deploying Monitoring------------"
cd terraform && \ 
terraform init 
terraform apply -auto-approve
cd ..

# Wait before updating kubeconfig
echo "--------------------Wait before updating kubeconfig--------------------"
sleep 60s

# Get GCP credentials
echo "--------------------Get Credentials--------------------"
gcloud iam service-accounts keys create ${filename} --iam-account ${service_account_email}

# Update kubeconfig
echo "--------------------Update Kubeconfig--------------------"
gcloud container clusters get-credentials ${cluster_name} --zone ${zone} --project ${project_id}

# Deploy Ingress
echo "--------------------Deploy Ingress--------------------"
kubectl apply -f ${ingress_deployment}

# remove preious docker images
echo "--------------------Remove Previous build--------------------"
docker rmi -f ${frontend_image_name} || true
docker rmi -f ${users_image_name} || true
docker rmi -f ${logout_image_name} || true
docker rmi -f ${sql_job_image_name} || true

# build new docker image with new tag
echo "--------------------Build new Image--------------------"
docker build -f ${app_path}/${frontend_dockerfile} -t ${frontend_image_name} ${app_path}
docker build -f ${app_path}/${users_dockerfile} -t ${users_image_name} ${app_path}
docker build -f ${app_path}/${logout_dockerfile} -t ${logout_image_name} ${app_path}
docker build -f k8s/mysql-job/${sql_job_dockerfile} -t ${sql_job_image_name} k8s/mysql-job

#GCR Authentication
echo "--------------------Authenticate Docker with GCR--------------------"
gcloud auth configure-docker

# push the latest build to dockerhub
echo "--------------------Pushing Docker Image--------------------"
docker push ${frontend_image_name}
docker push ${users_image_name}
docker push ${logout_image_name}
docker push ${sql_job_image_name}

# create app_namespace
echo "--------------------creating Namespace--------------------"
kubectl create ns ${app_namespace} || true

# Store the generated password in k8s secrets
echo "--------------------Store the generated password in k8s secret--------------------"
kubectl create secret generic ${cloudsql_endpoint} --from-literal=endpoint=${dbendpoint} --namespace=${app_namespace} || true
kubectl create secret generic ${dbsecretusername} --from-literal=username=${dbusername} --namespace=${app_namespace} || true
kubectl create secret generic ${dbsecretname} --from-literal=password=${db_generated_password} --namespace=${app_namespace} || true

# Deploy the application
echo "--------------------Deploy App--------------------"
kubectl apply -f k8s/ingress
kubectl apply -n ${app_namespace} -f k8s/frontend-service
kubectl apply -n ${app_namespace} -f k8s/logout-service
kubectl apply -n ${app_namespace} -f k8s/users-service
kubectl apply -n ${app_namespace} -f k8s/mysql-job

# Wait for application to be deployed
echo "--------------------Wait for all pods to be running--------------------"
sleep 90s

echo ""
echo "Cloud_SQL: " ${cloudsql_public_ip}
echo ""
echo "App_URL:" $(kubectl get svc ${ingress_svc} -n ${ingress_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Alertmanager_URL:" $(kubectl get svc ${alertmanager_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Prometheus_URL:" $(kubectl get svc ${prometheus_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Grafana_URL: " $(kubectl get svc ${grafana_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "ArgoCD_URL: " $(kubectl get svc ${argo_svc} -n ${argo_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')