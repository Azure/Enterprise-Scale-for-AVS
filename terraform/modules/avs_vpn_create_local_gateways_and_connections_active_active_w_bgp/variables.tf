variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "virtual_network_gateway_id" {
  type        = string
  description = "the Azure resource ID for the Azure VPN virtual network gateway where the connections will be associated "
}

#remote configurations
variable "remote_asn" {
  type        = number
  description = "The BGP ASN for the remote VPN"
}

variable "local_gateway_bgp_ip" {
  type        = string
  description = "the BGP peer IP for the remote VPN"
}

variable "local_gateway_name_0" {
  type        = string
  description = "The azure resource name"
}

variable "local_gateway_name_1" {
  type        = string
  description = "The azure resource name"
}

variable "vnet_gateway_connection_name_0" {
  type        = string
  description = "The azure resource name"
}

variable "vnet_gateway_connection_name_1" {
  type        = string
  description = "The azure resource name"
}

variable "remote_gateway_address_0" {
  type        = string
  description = "The public IP address for the remote VPN side 0 gateway"
}

variable "remote_gateway_address_1" {
  type        = string
  description = "The public IP address for the remote VPN side 1 gateway"
}

variable "bgp_peering_address_0" {
  type        = string
  description = "The BGP peering IP address for the hub VPN side 0"
}

variable "bgp_peering_address_1" {
  type        = string
  description = "The BGP peering IP address for the hub VPN side 1"
}

variable "shared_key" {
  description = "The shared key used by the vpn"
  sensitive   = true
}

