resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret" "db_credentials" {
  secret_id  = "${var.name_prefix}-${var.cloudsql_name}-secrets"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_credentials_version" {
  secret      = google_secret_manager_secret.db_credentials.id
  secret_data = jsonencode({
    "username" : var.db_username,
    "password" : random_password.password.result
  })
}