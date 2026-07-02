variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "domainshield-redis"
}

variable "tier" {
  description = "BASIC for trial/dev (no HA), STANDARD_HA for production."
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  type    = number
  default = 1
}

variable "redis_version" {
  type    = string
  default = "REDIS_7_0"
}
