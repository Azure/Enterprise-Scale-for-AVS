variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "vm_name" {
  type        = string
  description = "Name of the vm being configured"
}

variable "vm_sku" {
  type        = string
  description = "sku of the vm being deployed"
}

variable "logstash_subnet_id" {
  type        = string
  description = "resource id of the logstash subnet"
}

variable "logstash_values" {
  description = "Logstash configuration values for the deployment"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "key_vault_id" {
  type        = string
  description = "azure resource id for the keyvault used to store logstash vm passwords"
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