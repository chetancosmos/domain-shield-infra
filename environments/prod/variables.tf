variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "api_image" {
  description = "Initial api image. Cloud Build overwrites this on every deploy after bootstrap (see modules/cloud-run lifecycle.ignore_changes)."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "worker_image" {
  description = "Initial worker image. Cloud Build overwrites this on every deploy after bootstrap."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "jwt_secret" {
  description = "JWT signing secret. Generate with: openssl rand -hex 32"
  type        = string
  sensitive   = true
}

variable "sendgrid_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "sendgrid_from_email" {
  type    = string
  default = "alerts@domainshield.example.com"
}

variable "github_owner" {
  description = "GitHub username/org that owns the app repo (the one containing domain-shield-backend/)."
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repo name (not the full owner/repo path) containing domain-shield-backend/."
  type        = string
}
