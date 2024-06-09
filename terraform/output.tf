output "public_ip" {
  value       = google_sql_database_instance.instance.public_ip_address
  description = "The public IP address of the Cloud SQL instance"
}

output "cloud_sql_name" {
  value       = google_sql_database_instance.instance.name
  description = "The name of the Cloud SQL instance"
}

output "cluster_name" {
  value       = "${var.name_prefix}-${var.environment}"
  description = "The name of the GKE cluster"
}

output "project_id" {
  value       = var.project_id
  description = "The Google Cloud project ID"
}

output "db_username" {
  value       = var.db_username
  description = "The database username"
}

output "cluster_zone" {
  value = google_container_cluster.primary.location
}

output "cloudsql_public_ip" {
  value = google_sql_database_instance.instance.public_ip_address
}