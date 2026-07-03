locals {
  # google_service_account.runtime.email is treated as unknown-until-apply by
  # the provider even though it's fully deterministic from account_id +
  # project - computing it ourselves keeps it known at plan time, which
  # matters because other modules use it as a for_each key (see outputs.tf).
  service_account_id    = "${var.service_name}-run-sa"
  service_account_email = "${local.service_account_id}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = local.service_account_id
  display_name = "Runtime SA for Cloud Run service ${var.service_name}"
}

resource "google_project_iam_member" "extra_roles" {
  for_each = toset(var.extra_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_cloud_run_v2_service" "service" {
  project  = var.project_id
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.runtime.email
    timeout         = "${var.timeout_seconds}s"

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    # Direct VPC egress: reaches Cloud SQL / Memorystore over private IP without
    # the fixed monthly cost of a Serverless VPC Access connector's idle VMs.
    vpc_access {
      network_interfaces {
        network    = var.network_id
        subnetwork = var.subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.image

      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        # false = CPU always allocated (no throttling between requests), needed
        # for reliable fire-and-forget background work. Costs more since the
        # instance can't idle down to zero CPU - see var.cpu_idle description.
        cpu_idle = var.cpu_idle
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_env_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = var.allow_unauthenticated ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "restricted_invoker" {
  for_each = var.allow_unauthenticated ? toset([]) : toset(var.invoker_service_accounts)
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${each.value}"
}
