variable "project_id" {
  type = string
}

variable "topic_name" {
  type    = string
  default = "sentrydom-scan-jobs"
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
  description = "The worker acks immediately and processes each scan as a background task (see worker.py's /pubsub/push handler), so this only needs to cover envelope validation + task spawn - not the scan itself."
  type        = number
  default     = 60
}

variable "max_delivery_attempts" {
  type    = number
  default = 5
}
