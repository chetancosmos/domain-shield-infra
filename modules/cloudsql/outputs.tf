output "connection_name" {
  value = google_sql_database_instance.instance.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "instance_name" {
  value = google_sql_database_instance.instance.name
}

output "database_name" {
  value = google_sql_database.database.name
}

output "db_user" {
  value = google_sql_user.app_user.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "database_url" {
  description = "asyncpg-style connection string over private IP, for use as DATABASE_URL."
  value       = "postgresql+asyncpg://${google_sql_user.app_user.name}:${random_password.db_password.result}@${google_sql_database_instance.instance.private_ip_address}:5432/${google_sql_database.database.name}"
  sensitive   = true
}
