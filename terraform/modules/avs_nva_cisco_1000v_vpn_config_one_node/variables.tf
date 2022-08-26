variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "pre_shared_key" {
  type        = string
  description = "Shared secret for configuration"
  sensitive   = true
}

variable "asn" {
  type        = string
  description = "ASN value used for the Cisco CSR "
}

variable "csr_bgp_ip" {
  type        = string
  description = "BGP peer IP address"
}

variable "csr_tunnel_cidr" {
  type        = string
  description = "CIDR to use for the CSR tunnel IPs.  This is the IP subnet CIDR that is the internally routable IPs for the tunnel"
}

variable "csr_subnet_cidr" {
  type        = string
  description = "subnet value where the CSR is deployed"
}

variable "csr_vnet_cidr" {
  type        = string
  description = "vnet CIDR value where the CSR is deployed"
}

variable "remote_bgp_peer_ip_0" {
  type        = string
  description = "Remote bgp peer ip for active node 0"
}

variable "remote_bgp_peer_ip_1" {
  type        = string
  description = "Remote bgp peer ip for active node 0"
}

variable "remote_gw_pubip0" {
  type        = string
  description = "Remote peer public IP address 0"
}

variable "remote_gw_pubip1" {
  type        = string
  description = "Remote peer public IP address 1"
}

variable "node0_name" {
  type        = string
  description = "the vmname for the node0 CSR"
}

variable "fw_facing_subnet_id" {
  type        = string
  description = "the Azure resource id for the CSR subnet facing the firewall"
}

variable "keyvault_id" {
  type        = string
  description = "keyvault where the passwords are being stored"
}

variable "vpn_pip_name_1" {
  type        = string
  description = "Azure resource name assigned to the vpn public ip"
}
