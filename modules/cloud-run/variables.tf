variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "image" {
  description = "Full Artifact Registry image ref, e.g. asia-south1-docker.pkg.dev/PROJECT/domainshield/api:latest. Cloud Build overwrites the running revision's image on each deploy; this initial value just needs to exist so `terraform apply` succeeds the first time."
  type        = string
}

variable "port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "min_instance_count" {
  type    = number
  default = 0
}

variable "max_instance_count" {
  type    = number
  default = 3
}

variable "timeout_seconds" {
  description = "Max request duration. The worker sets this to 600 (Pub/Sub's max ack deadline) since it processes each scan synchronously before responding."
  type        = number
  default     = 300
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "env_vars" {
  description = "Plain (non-secret) environment variables."
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "Map of ENV_VAR_NAME => Secret Manager secret_id (latest version) to inject as env vars."
  type        = map(string)
  default     = {}
}

variable "allow_unauthenticated" {
  description = "true for the public-facing api service; false for the worker, which should only accept calls from the Pub/Sub push invoker service account."
  type        = bool
  default     = false
}

variable "invoker_service_accounts" {
  description = "Service account emails granted roles/run.invoker when allow_unauthenticated is false (e.g. the Pub/Sub push subscription's invoker SA)."
  type        = list(string)
  default     = []
}

variable "extra_sa_roles" {
  description = "Extra project-level IAM roles to grant this service's runtime service account (e.g. roles/storage.objectAdmin, roles/pubsub.publisher)."
  type        = list(string)
  default     = []
}
