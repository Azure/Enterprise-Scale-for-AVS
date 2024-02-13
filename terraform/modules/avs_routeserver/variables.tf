#################################################################
# module variables
#################################################################
variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "virtual_hub_name" {
  type        = string
  description = "The azure resource name for the virtual hub housing the route server"
}

variable "virtual_hub_pip_name" {
  type        = string
  description = "Azure resource name assigned to the virtual hub public ip"
}

variable "route_server_name" {
  type        = string
  description = "Azure resource name assigned to the routeserver"
}

variable "route_server_subnet_id" {
  type        = string
  description = "The full resource id for the route server subnet"
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