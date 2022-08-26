variable "rg_name" {
  type        = string
  description = "Resource Group Name where firewall and the associated public ip are being deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "firewall_sku_tier" {
  type        = string
  description = "Firewall Sku Tier - allowed values are Standard and Premium"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Value must be Standard or Premium."
  }
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "firewall_name" {
  type        = string
  description = "Azure resource name assigned to the firewall"
}

variable "log_analytics_name" {
  type        = string
  description = "Azure resource name assigned to the log analytics workspace"
}

variable "vwan_firewall_policy_name" {
  type        = string
  description = "Azure resource name assigned to the base vwan firewall policy"
}

variable "virtual_hub_id" {
  type        = string
  description = "Azure resource id for the virtual hub that this firewall will be linked to."
}

variable "public_ip_count" {
  type        = number
  description = "The number of public ip addresses to provision on this firewall"
}

