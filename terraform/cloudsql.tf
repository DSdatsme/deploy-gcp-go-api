# This deploys CloudSQL
resource "google_sql_database_instance" "database-server" {
  name                = "app-database-server"
  database_version    = "POSTGRES_12"
  region              = var.default_gcp_region
  deletion_protection = "false" # WARNING: this is not for prod

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_autoresize   = "false"
    disk_size         = 10

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "projects/${var.gcp_default_project_id}/global/networks/${module.vpc.network_name}"
    }

    user_labels = {
      purpose     = "hosting"
      deployed-by = "terraform"
      env         = "dev"
    }
  }

  depends_on = [
    google_service_networking_connection.peer-db
  ]
}


resource "google_sql_user" "root-db-user" {
  # re-create password for root user
  # NOTE: when deleting the env, you will have to manually delete this from state and then destory the env
  name     = "postgres"
  instance = google_sql_database_instance.database-server.name
  password = var.sql_password
}
