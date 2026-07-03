output "url" {
  value = google_cloud_run_v2_service.service.uri
}

output "service_account_email" {
  value = local.service_account_email
  # Consumers (e.g. modules/secrets, modules/storage IAM bindings) need the SA
  # to actually exist before granting it roles, even though the email string
  # itself is known at plan time without waiting on the resource.
  depends_on = [google_service_account.runtime]
}

output "service_name" {
  value = google_cloud_run_v2_service.service.name
}
