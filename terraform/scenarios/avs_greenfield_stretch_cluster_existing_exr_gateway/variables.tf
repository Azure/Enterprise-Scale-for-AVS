variable "prefix" {
  type        = string
  description = "Simple prefix used for naming convention prepending"
}

variable "region" {
  type        = string
  description = "Deployment region for the new AVS private cloud resources"
}



variable "sddc_sku" {
  type        = string
  description = "The sku value for the AVS SDDC management cluster nodes"
  default     = "av36P"
}

variable "management_cluster_size" {
  type        = number
  description = "The number of nodes to include in the management cluster"
  default     = 3
}

variable "avs_network_cidr" {
  type        = string
  description = "The full /22 network CIDR range summary for the private cloud managed components"
}

variable "expressroute_gateway_id" {
  type        = string
  description = "the gateway ID of the expressRoute gateway being connected"
}

variable "hcx_enabled" {
  type        = bool
  description = "Enable the HCX addon toggle value"
  default     = false
}

variable "hcx_key_names" {
  type        = list(string)
  description = "list of key names to use when generating hcx site activation keys."
  default     = []
}

variable "internet_enabled" {
  type        = bool
  description = "set the internet snat to on or off"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "email_addresses" {
  type        = list(string)
  description = "A list of email addresses where service health alerts will be sent"
}

variable "telemetry_enabled" {
  type        = bool
  description = "toggle the telemetry on/off for this module"
  default     = true
}