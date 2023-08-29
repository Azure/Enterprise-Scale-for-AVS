#################################################################
# module variables
#################################################################
variable "sddc_name" {
  type        = string
  description = "Azure resource name assigned to the avs sddc being created"
}

variable "sddc_sku" {
  type        = string
  description = "The sku value for the AVS SDDC management cluster nodes"
}

variable "management_cluster_size" {
  type        = number
  description = "The number of nodes to include in the management cluster"
  default     = 3
}

variable "rg_name" {
  type        = string
  description = "Resource Group Name where the expressroute gateway and the associated public ip are being deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "avs_network_cidr" {
  type        = string
  description = "The full /22 network CIDR range summary for the private cloud managed components"
}

variable "expressroute_authorization_key_prefix" {
  type        = string
  description = "The prefix used to generate the for the expressRoute authorization key"
}

variable "expressroute_gateway_id" {
  type        = string
  description = "The resource ID for the expressRoute gateway where the private cloud is attached."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "internet_enabled" {
  type        = bool
  description = "set the internet snat to on or off"
  default     = false
}

variable "hcx_enabled" {
  type        = bool
  description = "Enable the HCX addon toggle value"
  default     = false
}

variable "hcx_key_prefix" {
  type        = string
  description = "prefix used to generate the hcx access key names."
}

variable "attach_to_expressroute_gateway" {
  type        = bool
  description = "Toggle off the expressRoute connection if this private cloud is only global reach connected"
  default     = false
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