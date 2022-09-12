variable "rg_name" {
  type        = string
  description = "Resource Group Name where the jumpbox is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "vwan_id" {
  type        = string
  description = "azure resource ID for the VWAN resource"
}

variable "vwan_hub_name" {
  type        = string
  description = "Azure resource name assigned to the vwan"
}

variable "vwan_hub_address_prefix" {
  type        = string
  description = "The address prefix for the VWAN hub.  Should be a /24 or larger. /23 recommended"
}

variable "express_route_gateway_name" {
  type        = string
  description = "The azure resource name for the express route gateway in the vwan hub"
}

variable "express_route_connection_name" {
  type        = string
  description = "The azure resource name for the express route connection to the AVS private cloud"
}

variable "express_route_circuit_peering_id" {
  type        = string
  description = "The peering id for the AVS Private Cloud Express Route circuit"
}

variable "express_route_authorization_key" {
  type        = string
  description = "The authorization key for connecting the AVS private cloud express route circuit to the gateway"
}

variable "express_route_scale_units" {
  type        = number
  description = "the number of scale units to assign to the Express route gateway.  Each unit represents 2GB.  Value must be in range 1-10"
}

variable "azure_firewall_id" {
  type        = string
  description = "The firewall ID associated to this hub when it is a secure hub"
  default     = "null"
}

variable "all_branch_traffic_through_firewall" {
  type        = bool
  description = "This flag determines whether to enable the vwan hub to route all branch traffic through the virtual hub azure firewall."
  default     = false
}

variable "vpn_gateway_name" {
  type        = string
  description = "The azure resource name for the vpn gateway in the vwan hub"
}

variable "vpn_scale_units" {
  type        = number
  description = "the number of scale units to assign to the VPN gateway.  Each unit represents 500mbps."
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "private_range_prefixes" {
  type        = list(string)
  description = "List of rfc1918 prefixes to next-hop to the firewall as part of the default route table default route"
}