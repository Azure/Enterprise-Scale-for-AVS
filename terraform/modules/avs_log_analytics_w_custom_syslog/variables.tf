variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}


variable "log_analytics_name" {
  type        = string
  description = "The name of the log analytics workspace that will receive the syslogs"
}

variable "custom_table_name" {
  type        = string
  description = "The name for the custom table that will hold the syslogs"
}

variable "data_collection_endpoint_name" {
  type        = string
  description = "The name for the data collection endpoint that the logstash log analytics plugin uses"
}

variable "data_collection_rule_name" {
  type        = string
  description = "Name of the data collection rule used by the logstash log analytics plugin"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "log_processing_principal_object_id" {
  type        = string
  description = "object id of the log processing service principal"
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