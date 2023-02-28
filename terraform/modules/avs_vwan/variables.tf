#################################################################
# module variables
#################################################################
variable "rg_name" {
  type        = string
  description = "Resource Group Name where the vwan is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "vwan_name" {
  type        = string
  description = "Azure resource name assigned to the vwan"
  default     = ""
}

variable "vwan_already_exists" {
  type        = bool
  description = "Flag value that indicates whether a VWAN already exists. If set to false a new VWAN will be created"
  default     = true
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