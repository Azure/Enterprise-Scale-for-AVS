variable "jumpbox_nic_name" {
  type        = string
  description = "Azure resource name assigned to the jumpbox network interface"
}

variable "jumpbox_name" {
  type        = string
  description = "Azure resource name assigned to the jumpbox"
}

variable "jumpbox_sku" {
  type        = string
  description = "The sku for the jumpbox vm"
  default     = "Standard_D2as_v4"
}

variable "rg_name" {
  type        = string
  description = "Resource Group Name where the jumpbox is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "jumpbox_subnet_id" {
  type        = string
  description = "The full resource id for the subnet where the jumpbox will be deployed"
}

variable "admin_username" {
  type        = string
  description = "The username for the jumpbox admin login"
}

variable "key_vault_id" {
  type        = string
  description = "The resource id for the keyvault used to store the jumpbox admin password as a secret"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}