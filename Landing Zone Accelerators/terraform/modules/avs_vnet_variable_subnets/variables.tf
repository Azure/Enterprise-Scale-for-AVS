#################################################################
# module variables
#################################################################
variable "rg_name" {
  type        = string
  description = "Resource Group Name where the jumpbox is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "vnet_name" {
  type        = string
  description = "azure resource name for the spoke vnet"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space summaries for the spoke Vnet"
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = list(string)
  }))
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

variable "has_root_telemetry" {
  type        = bool
  description = "Tell the telemetry logic if this module is a submodule to a root module with telemetry"
  default     = false
}

variable "guid_telemetry" {
  type        = string
  description = "guid used for telemetry identification. Defaults to module guid, but overrides with root if needed."
  default     = "0f9a8adc-9d37-40b3-aaed-ab34b95cf6dd"
}