resource "google_pubsub_topic" "scan_jobs" {
  project                    = var.project_id
  name                       = var.topic_name
  message_retention_duration = var.message_retention_duration
}

resource "google_pubsub_topic" "dead_letter" {
  project = var.project_id
  name    = "${var.topic_name}-dlq"
}

# Identity the push subscription uses to sign OIDC tokens; the worker Cloud Run
# service must grant this SA the run.invoker role (see cloud-run module).
resource "google_service_account" "pubsub_invoker" {
  project      = var.project_id
  account_id   = "${var.topic_name}-invoker"
  display_name = "Pub/Sub push invoker for ${var.topic_name}"
}

resource "google_pubsub_subscription" "scan_jobs_push" {
  count   = var.push_endpoint == null ? 0 : 1
  project = var.project_id
  name    = "${var.topic_name}-push"
  topic   = google_pubsub_topic.scan_jobs.id

  ack_deadline_seconds = var.ack_deadline_seconds

  push_config {
    push_endpoint = var.push_endpoint
    oidc_token {
      service_account_email = google_service_account.pubsub_invoker.email
    }
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = var.max_delivery_attempts
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

# Lets Pub/Sub's service agent republish failed messages onto the DLQ.
resource "google_pubsub_topic_iam_member" "dead_letter_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.dead_letter.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_subscription_iam_member" "dead_letter_subscriber" {
  count        = var.push_endpoint == null ? 0 : 1
  project      = var.project_id
  subscription = google_pubsub_subscription.scan_jobs_push[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}
