variable "prefix" {
  type        = string
  description = "Simple prefix used for naming convention prepending"
}

variable "region" {
  type        = string
  description = "Deployment region for the new AVS private cloud resources"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "List of CIDR ranges assigned to the hub VNET.  Typically one larger range."
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = list(string)
  }))
}

variable "expressroute_gateway_sku" {
  type        = string
  description = "The sku for the AVS expressroute gateway"
  default     = "Standard"
}

variable "sddc_sku" {
  type        = string
  description = "The sku value for the AVS SDDC management cluster nodes"
  default     = "av36"
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

variable "vpn_gateway_sku" {
  type        = string
  description = "The sku for the AVS vpn gateway"
  default     = "VpnGw2"
}

variable "asn" {
  type        = number
  description = "The ASN for bgp on the VPN gateway"
  default     = "65515"
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

variable "email_addresses" {
  type        = list(string)
  description = "A list of email addresses where service health alerts will be sent"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "jumpbox_sku" {
  type        = string
  description = "The sku for the jumpbox vm"
  default     = "Standard_D2as_v4"
}

variable "jumpbox_admin_username" {
  type        = string
  description = "The username for the jumpbox admin login"
}

variable "jumpbox_spoke_vnet_address_space" {
  type        = list(string)
  description = "Address space summaries for the spoke Vnet"
}

variable "bastion_subnet_prefix" {
  type        = list(string)
  description = "A list of subnet prefix CIDR values used for the bastion subnet address space"
}

variable "jumpbox_subnet_prefix" {
  type        = list(string)
  description = "A list of subnet prefix CIDR values used for the jumpbox subnet address space"
}