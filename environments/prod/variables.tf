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

variable "worker_always_on" {
  description = "false (default): worker scales to zero, cheap. true: min_instance_count=1 + CPU always allocated, so long-running scans (large brand names) can finish reliably in the background without the instance being evicted mid-scan. Flip on before a big scan, off after to stop paying for it."
  type        = bool
  default     = false
}

variable "frontend_image" {
  description = "Initial frontend image. Deployed manually via docker build/push + gcloud run deploy (see domain-shield-frontend/Dockerfile) - no Cloud Build wiring for this one yet."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "frontend_allow_unauthenticated" {
  description = "true = anyone with the URL can load the app (needed for real users to reach it). Set false to lock it down to specific IAM principals later - same toggle used for api/worker."
  type        = bool
  default     = true
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
  description = "GitHub username/org that owns the domain-shield-backend repo."
  type        = string
}

variable "github_repo_name" {
  description = "The domain-shield-backend repo name (it's its own repo, not a monorepo subfolder)."
  type        = string
}

variable "github_deploy_branch" {
  description = "Branch regex Cloud Build watches for pushes. Defaults to main; set to ^feature-gcp$ while that's still the active development branch."
  type        = string
  default     = "^main$"
}
