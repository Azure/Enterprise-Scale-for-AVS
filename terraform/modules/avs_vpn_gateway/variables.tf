variable "vpn_pip_name_1" {
  type        = string
  description = "Azure resource name assigned to the vpn public ip"
}

variable "vpn_pip_name_2" {
  type        = string
  description = "Azure resource name assigned to the vpn public ip"
}

variable "vpn_gateway_name" {
  type        = string
  description = "Azure resource name assigned to the AVS vpn gateway instance"
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

variable "rg_name" {
  type        = string
  description = "Resource Group Name where the expressroute gateway and the associated public ip are being deployed"
}
variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}
variable "gateway_subnet_id" {
  type        = string
  description = "The full resource id for the subnet where the bastion will be deployed"
}