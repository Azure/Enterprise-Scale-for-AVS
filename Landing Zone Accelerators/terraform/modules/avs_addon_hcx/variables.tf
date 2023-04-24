#################################################################
# module variables
#################################################################
variable "private_cloud_name" {
  type        = string
  description = "name of the private cloud where the hcx addon will be enabled"
}

variable "private_cloud_resource_group" {
  type        = string
  description = "name of the resource group where the private cloud is deployed"
}

variable "hcx_key_names" {
  type        = list(string)
  description = "list of key names to use when generating hcx site activation keys."
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