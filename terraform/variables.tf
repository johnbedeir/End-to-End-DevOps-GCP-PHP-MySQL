
variable "project_id" {
  description = "The name of the VPC to use."
  type        = string
}


variable "region" {
  description = "The name of the VPC to use."
  type        = string
}

variable "name_prefix" {
  description = "The name of the VPC to use."
  type        = string
  default     = "cluster-1"
}

variable "environment" {
  type    = string
  default = "testing-env"
}

variable "db_username" {
  description = "The database username"
  type        = string
}

variable "database_name" {
  description = "The database username"
  type        = string
}

variable "cloudsql_name" {
  description = "The google cloudsql name"
  type        = string
  default     = "cloudsql"
}

variable "gke_service_account_email" {
  description = "The email of the service account to grant Cloud SQL client role"
  type        = string
}


