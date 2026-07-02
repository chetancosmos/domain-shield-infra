variable "project_id" {
  type = string
}

variable "secrets" {
  description = "Map of secret_id => secret value. A Secret Manager secret + initial version is created for each entry."
  type        = map(string)
  sensitive   = true
}

variable "accessor_service_accounts" {
  description = "Service account emails (e.g. Cloud Run runtime SAs) granted roles/secretmanager.secretAccessor on every secret in this map."
  type        = list(string)
  default     = []
}
