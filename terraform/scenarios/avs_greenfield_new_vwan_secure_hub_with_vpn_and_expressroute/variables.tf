variable "prefix" {
  type        = string
  description = "Simple prefix used for naming convention prepending"
}

variable "region" {
  type        = string
  description = "Deployment region for the new AVS private cloud resources"
}

variable "vwan_name" {
  type        = string
  description = "Azure resource name assigned to the vwan"
  default     = ""
}

variable "vwan_already_exists" {
  type        = bool
  description = "Flag value that indicates whether a VWAN already exists. If set to false a new VWAN will be created"
  default     = true
}

variable "vwan_hub_address_prefix" {
  type        = string
  description = "The full CIDR range summary for the vwan hub. A /23 is recommended, nothing smaller than a /24"
}

variable "express_route_scale_units" {
  type        = number
  description = "the number of scale units to assign to the Express route gateway.  Each unit represents 2GB.  Value must be in range 1-10"
  default     = 1
}

variable "all_branch_traffic_through_firewall" {
  type        = bool
  description = "This flag determines whether to enable the AVS expressroute internet connectivity through the virtual hub firewall if one has been deployed."
  default     = false
}

variable "vpn_scale_units" {
  type        = number
  description = "the number of scale units to assign to the VPN gateway.  Each unit represents 500mbps."
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

variable "firewall_sku_tier" {
  type        = string
  description = "Firewall Sku Tier - allowed values are Standard and Premium"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Value must be Standard or Premium."
  }
}

variable "hub_firewall_public_ip_count" {
  type        = number
  description = "The number of public ip addresses to provision on this firewall"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "email_addresses" {
  type        = list(string)
  description = "A list of email addresses where service health alerts will be sent"
}

/*
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

variable "jumpbox_sku" {
  type        = string
  description = "The sku for the jumpbox vm"
  default     = "Standard_D2as_v4"
}

variable "admin_username" {
  type        = string
  description = "The username for the jumpbox admin login"
}
*/
