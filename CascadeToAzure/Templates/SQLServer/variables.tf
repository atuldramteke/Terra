variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location for all resources."
}

variable "vm_size" {
  type        = string
  description = "The size of the vm to be created."
  default     = "Standard_B2ms"
}

variable "user_name" {
  type        = string
  description = "The username for the local account that will be created on the new vm."
  default     = "adminuser"
}

variable "password" {
  type        = string
  description = "The password for the local account that will be created on the new vm."
  sensitive   = true
}

variable "sql_count" {
  description = "Number of SQL VMs"
  type        = number
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "subscription_id" {
  description = "subscription"
  default = "77b6cca9-e832-4a34-bac4-08fc70b5e30f"
}