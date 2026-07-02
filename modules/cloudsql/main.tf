resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "instance" {
  project             = var.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    # Plain daily backups only (no PITR) - PITR's WAL retention adds ongoing
    # storage cost that isn't worth it for a 3-4 user POC.
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = false
    }
  }
}

resource "google_sql_database" "database" {
  project  = var.project_id
  name     = var.database_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "app_user" {
  project  = var.project_id
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}
