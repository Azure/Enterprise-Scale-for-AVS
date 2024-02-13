variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "eventhub_namespace_name" {
  type        = string
  description = "The name for the eventhub namespace"
}

variable "eventhub_capacity" {
  type        = number
  description = "The number of eventhub capacity units on the namespace"
  default     = 8
}

variable "eventhub_name" {
  type        = string
  description = "The name of the eventhub where the logs are being sent"
}

variable "eventhub_partition_count" {
  type        = number
  description = "The number of partitions for the eventhub"
  default     = 2
}

variable "eventhub_message_retention_days" {
  type        = number
  description = "The number of days for message retention"
  default     = 3
}

variable "diagnostic_eventhub_authorization_rule_name" {
  type        = string
  description = "Name for the authorization rule used by the eventhub diagnostic setting"
}

variable "logstash_eventhub_authorization_rule_name" {
  type        = string
  description = "Name for the authorization rule used by the logstash event hub plugin"
}

variable "consumer_group_name" {
  type        = string
  description = "The consumer group name for the event hub plugin to process the logs."
}

variable "plugin_storage_account_name" {
  type        = string
  description = "The storage account name for the storage account used by the logstash event hub plugin as a witness."
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

