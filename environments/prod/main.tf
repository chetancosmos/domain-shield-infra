module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.apis]
}

module "artifact_registry" {
  source     = "../../modules/artifact-registry"
  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.apis]
}

module "cloudsql" {
  source     = "../../modules/cloudsql"
  project_id = var.project_id
  region     = var.region
  network_id = module.network.network_id

  depends_on = [module.network]
}

module "memorystore" {
  source     = "../../modules/memorystore"
  project_id = var.project_id
  region     = var.region
  network_id = module.network.network_id

  depends_on = [module.network]
}

module "storage" {
  source      = "../../modules/storage"
  project_id  = var.project_id
  region      = var.region
  bucket_name = "${var.project_id}-domainshield-screenshots"

  reader_service_accounts = [module.cloud_run_api.service_account_email]
  writer_service_accounts = [module.cloud_run_worker.service_account_email]
}

module "secrets" {
  source     = "../../modules/secrets"
  project_id = var.project_id

  secrets = {
    "domainshield-db-password"      = module.cloudsql.db_password
    "domainshield-database-url"     = module.cloudsql.database_url
    "domainshield-redis-url"        = module.memorystore.redis_url
    "domainshield-jwt-secret"       = var.jwt_secret
    "domainshield-sendgrid-api-key" = var.sendgrid_api_key
  }

  accessor_service_accounts = [
    module.cloud_run_api.service_account_email,
    module.cloud_run_worker.service_account_email,
  ]
}

module "pubsub" {
  source        = "../../modules/pubsub"
  project_id    = var.project_id
  push_endpoint = "${module.cloud_run_worker.url}/pubsub/push"
}

module "cloud_run_api" {
  source                = "../../modules/cloud-run"
  project_id            = var.project_id
  region                = var.region
  service_name          = "domainshield-api"
  image                 = var.api_image
  network_id            = module.network.network_id
  subnet_id             = module.network.subnet_id
  min_instance_count    = 0
  max_instance_count    = 2
  allow_unauthenticated = true

  env_vars = {
    GCS_BUCKET_NAME = "${var.project_id}-domainshield-screenshots"
    PUBSUB_TOPIC_ID = module.pubsub.topic_name
    GCP_PROJECT_ID  = var.project_id
    ENVIRONMENT     = "production"
    # notifier.py speaks plain SMTP - SendGrid's relay accepts it directly, no
    # SendGrid-specific SDK/code needed. ALERT_EMAIL_ENABLED flips on once a
    # real API key is supplied via sendgrid_api_key.
    SMTP_HOST           = "smtp.sendgrid.net"
    SMTP_PORT           = "587"
    SMTP_USER           = "apikey"
    SMTP_FROM           = var.sendgrid_from_email
    ALERT_EMAIL_ENABLED = var.sendgrid_api_key != "" ? "true" : "false"
  }

  secret_env_vars = {
    DATABASE_URL  = module.secrets.secret_ids["domainshield-database-url"]
    REDIS_URL     = module.secrets.secret_ids["domainshield-redis-url"]
    JWT_SECRET    = module.secrets.secret_ids["domainshield-jwt-secret"]
    SMTP_PASSWORD = module.secrets.secret_ids["domainshield-sendgrid-api-key"]
  }

  extra_sa_roles = [
    "roles/pubsub.publisher",
  ]
}

module "cloud_run_worker" {
  source                = "../../modules/cloud-run"
  project_id            = var.project_id
  region                = var.region
  service_name          = "domainshield-worker"
  image                 = var.worker_image
  network_id            = module.network.network_id
  subnet_id             = module.network.subnet_id
  min_instance_count    = 0
  max_instance_count    = 2
  timeout_seconds       = 600
  allow_unauthenticated = false

  env_vars = {
    GCS_BUCKET_NAME = "${var.project_id}-domainshield-screenshots"
    GCP_PROJECT_ID  = var.project_id
    ENVIRONMENT     = "production"
    # send_threat_alert() runs inside the scan pipeline, so the worker needs
    # the same SMTP config as the api service.
    SMTP_HOST           = "smtp.sendgrid.net"
    SMTP_PORT           = "587"
    SMTP_USER           = "apikey"
    SMTP_FROM           = var.sendgrid_from_email
    ALERT_EMAIL_ENABLED = var.sendgrid_api_key != "" ? "true" : "false"
  }

  secret_env_vars = {
    DATABASE_URL = module.secrets.secret_ids["domainshield-database-url"]
    REDIS_URL    = module.secrets.secret_ids["domainshield-redis-url"]
    # JWT_SECRET isn't used by worker logic, but Settings() validates it as
    # required at import time - omitting it would crash the container on boot.
    JWT_SECRET    = module.secrets.secret_ids["domainshield-jwt-secret"]
    SMTP_PASSWORD = module.secrets.secret_ids["domainshield-sendgrid-api-key"]
  }
}

# Grant the pubsub push invoker permission to call the worker, now that both exist.
resource "google_cloud_run_v2_service_iam_member" "worker_pubsub_invoker" {
  project  = var.project_id
  location = var.region
  name     = module.cloud_run_worker.service_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${module.pubsub.invoker_service_account_email}"
}
