#################################################################
# module variables
#################################################################
variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "action_group_name" {
  type        = string
  description = "The azure resource name for the AVS action group"
}

variable "action_group_shortname" {
  type        = string
  description = "The azure resource name for the AVS action group shortname"
}

variable "email_addresses" {
  type        = list(string)
  description = "A list of email addresses where service health alerts will be sent"
}

variable "service_health_alert_name" {
  type        = string
  description = "The azure resource name for the service health alert"
}

variable "service_health_alert_scope_id" {
  type        = string
  description = "The full azure resource id of the scope where this service health alert will notify on. Initially set to the resource group of the AVS private cloud"
}

variable "private_cloud_id" {
  type        = string
  description = "The Azure resource id for the AVS private cloud resource"
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
