variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  description = "Self link / id of the VPC to attach the private IP to."
  type        = string
}

variable "instance_name" {
  type    = string
  default = "sentrydom-pg"
}

variable "database_version" {
  type    = string
  default = "POSTGRES_15"
}

variable "tier" {
  description = "Machine tier. db-f1-micro (cheapest shared-core, ~$8-10/mo) is the POC default here. Move to db-custom-* when this grows past a handful of users."
  type        = string
  default     = "db-f1-micro"
}

variable "database_name" {
  type    = string
  default = "sentrydom"
}

variable "db_user" {
  type    = string
  default = "sentrydom_app"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "availability_type" {
  description = "ZONAL for trial/dev, REGIONAL for HA production."
  type        = string
  default     = "ZONAL"
}
