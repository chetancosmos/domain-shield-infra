variable "project_id" {
  type = string
}

variable "topic_name" {
  type    = string
  default = "domainshield-scan-jobs"
}

variable "push_endpoint" {
  description = "Full HTTPS URL of the worker's Pub/Sub push route, e.g. https://<worker-url>/pubsub/push. Leave null to create the topic/DLQ without a subscription (useful on first apply before the worker Cloud Run URL exists)."
  type        = string
  default     = null
}

variable "message_retention_duration" {
  type    = string
  default = "604800s" # 7 days
}

variable "ack_deadline_seconds" {
  description = "600s (Pub/Sub's max) since the worker processes each scan synchronously before acking - see worker.py's /pubsub/push handler."
  type        = number
  default     = 600
}

variable "max_delivery_attempts" {
  type    = number
  default = 5
}
