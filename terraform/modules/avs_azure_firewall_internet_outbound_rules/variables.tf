variable "firewall_policy_id" {
  type        = string
  description = "The Azure resource id for the azure firewall policy that this rule will be applied to"
  default     = ""
}


variable "azure_firewall_name" {
  type        = string
  description = "The Azure resource name of the azure firewall when deploying with a classic rule collection group"
  default     = ""
}

variable "azure_firewall_rg_name" {
  type        = string
  description = "The Azure resource group name where the azure firewall is deployed when using a classic rule collection group"
  default     = ""
}

variable "private_range_prefixes" {
  type        = list(string)
  description = "The RFC1918 non-routable summaries"
}

variable "has_firewall_policy" {
  type        = bool
  description = "A flag variable for setting when to create test rules for azure policy or create classic rule collection"
  default     = false
}
