variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  type    = string
  default = "domainshield-vpc"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/20"
}

variable "private_services_cidr_prefix" {
  description = "Prefix length for the reserved range used for VPC peering with Google-managed services (Cloud SQL, Memorystore)."
  type        = number
  default     = 16
}
