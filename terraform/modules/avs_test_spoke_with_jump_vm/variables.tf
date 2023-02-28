#################################################################
# module variables
#################################################################
variable "prefix" {
  type        = string
  description = "Simple prefix used for naming convention prepending"
}

variable "region" {
  type        = string
  description = "Deployment region for the new AVS private cloud resources"
}

variable "jumpbox_sku" {
  type        = string
  description = "The sku for the jumpbox vm"
  default     = "Standard_D2as_v4"
}

variable "admin_username" {
  type        = string
  description = "The username for the jumpbox admin login"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub vnet this spoke vNet will connect to"
}

variable "hub_rg_name" {
  type        = string
  description = "Name of the hub vnet this spoke vNet will connect to"
}

variable "jumpbox_spoke_vnet_address_space" {
  type        = list(string)
  description = "Address space summaries for the spoke Vnet"
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "A subnet prefix CIDR value used for the bastion subnet address space"
}

variable "jumpbox_subnet_prefix" {
  type        = string
  description = "A subnet prefix CIDR value used for the jumpbox subnet address space"
}

#################################################################
# telemetry variables
#################################################################
variable "module_telemetry_enabled" {
  type        = bool
  description = "toggle the telemetry on/off for this module"
  default     = true
}

variable "guid_telemetry" {
  type        = string
  description = "guid used for telemetry identification. Defaults to module guid, but overrides with root if needed."
  default     = "0f9a8adc-9d37-40b3-aaed-ab34b95cf6dd"
}