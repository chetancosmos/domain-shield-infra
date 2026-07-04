output "api_url" {
  value = module.cloud_run_api.url
}

output "worker_url" {
  value = module.cloud_run_worker.url
}

output "frontend_url" {
  value = module.cloud_run_frontend.url
}

output "artifact_registry_url" {
  value = module.artifact_registry.repository_url
}

output "cloudsql_connection_name" {
  value = module.cloudsql.connection_name
}

output "cloudsql_private_ip" {
  value = module.cloudsql.private_ip_address
}

output "pubsub_topic" {
  value = module.pubsub.topic_name
}

output "screenshots_bucket" {
  value = module.storage.bucket_name
}
