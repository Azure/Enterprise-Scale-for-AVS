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

variable "firewall_pip_name" {
  type        = string
  description = "Azure resouuce name assigned to the firewall public ip"
}

variable "firewall_name" {
  type        = string
  description = "Azure resource name assigned to the firewall"
}

variable "firewall_subnet_id" {
  type        = string
  description = "The full resource id for the subnet where the firewall will be deployed"
}

variable "log_analytics_name" {
  type        = string
  description = "Azure resource name assigned to the log analytics workspace"
}

variable "firewall_policy_name" {
  type        = string
  description = "Azure resource name assigned to the lfirewall policy"
}