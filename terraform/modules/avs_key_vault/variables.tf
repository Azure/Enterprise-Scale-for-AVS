variable "rg_name" {
  type        = string
  description = "Resource Group Name where the key vault is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "keyvault_name" {
  type        = string
  description = "Resource Name for the key vault"
}

variable "azure_ad_tenant_id" {
  type        = string
  description = "ID value for the azure AD tenant for the user running the script"
}

#variable "service_principal_object_id" {}

variable "deployment_user_object_id" {
  type        = string
  description = "ID value for the user running the script"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}
