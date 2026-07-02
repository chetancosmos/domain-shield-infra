variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket_name" {
  description = "Globally unique GCS bucket name for screenshot storage, e.g. domainshield-screenshots-<project_id>."
  type        = string
}

variable "reader_service_accounts" {
  description = "SAs that need to read screenshots (api service, for generating signed URLs)."
  type        = list(string)
  default     = []
}

variable "writer_service_accounts" {
  description = "SAs that need to write screenshots (worker service)."
  type        = list(string)
  default     = []
}

variable "screenshot_retention_days" {
  description = "Auto-delete screenshots older than this many days. 0 disables the lifecycle rule."
  type        = number
  default     = 90
}
