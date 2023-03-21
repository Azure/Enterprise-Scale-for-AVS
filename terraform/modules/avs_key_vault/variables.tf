#################################################################
# module variables
#################################################################
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