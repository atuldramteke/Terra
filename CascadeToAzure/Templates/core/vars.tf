# add variables

variable "resource_group_location" {
  description = "The region in which the resources"
  default     = "eastus"
}

variable "subscription_id" {
  description = "subscription"
  default = "35217a63-b412-434b-862a-4ea348a188e4"
}

variable "environment" {
  description = "The environment to deploy the resources"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  
}

variable "snet_iis_address_prefix" {
  description = "The address space for the virtual network"
  
}

variable "snet_sql_address_prefix" {
  description = "The address space for the virtual network"
  
}

variable "snet_db_address_prefix" {
  description = "The address space for the virtual network"
  
}