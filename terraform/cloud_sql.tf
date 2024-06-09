resource "google_sql_database_instance" "instance" {
  name             = "${var.cloudsql_name}-${var.environment}"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "public-connections"
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = var.db_username
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
}

resource "google_project_iam_member" "gke_to_sql" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${var.gke_service_account_email}"
}