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
