variable "hub_rg_location" {}
variable "hub_prefix" {}
variable "hub_vnet_address_space" {}
variable "hub_subnets" {}
variable "hub_expressroute_gateway_sku" {}
variable "transit_hub_rg_location" {}
variable "transit_hub_prefix" {}
variable "transit_hub_vnet_address_space" {}
variable "transit_hub_subnets" {}
variable "transit_hub_expressroute_gateway_sku" {}
variable "private_cloud_rg_prefix" {}
variable "private_cloud_location" {}
variable "avs_private_clouds" {}
variable "onprem_enabled" {}
variable "onprem_private_cloud_rg_prefix" {}
variable "onprem_private_cloud_location" {}
variable "onprem_private_clouds" {}
variable "tags" {}
variable "telemetry_enabled" {

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