output "topic_id" {
  value = google_pubsub_topic.scan_jobs.id
}

output "topic_name" {
  value = google_pubsub_topic.scan_jobs.name
}

output "dead_letter_topic_id" {
  value = google_pubsub_topic.dead_letter.id
}

output "invoker_service_account_email" {
  value = google_service_account.pubsub_invoker.email
}

output "subscription_name" {
  value = var.push_endpoint == null ? null : google_pubsub_subscription.scan_jobs_push[0].name
}
