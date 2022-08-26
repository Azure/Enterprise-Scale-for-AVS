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

variable "csr_bgp_ip" {
  type        = string
  description = "BGP peer IP address"
}

variable "csr_tunnel_cidr" {
  type        = string
  description = "CIDR to use for the CSR tunnel IPs.  This is the IP subnet CIDR that is the internally routable IPs for the tunnel"
}

variable "csr_subnet_name" {
  type        = string
  description = "Name of the subnet where the CSR is deployed"
}

variable "remote_bgp_peer_ips" {
  type        = list(string)
  description = "Remote bgp peer ip for active node 0"
}

variable "pre_shared_key" {
  type        = string
  description = "shared key for the vpn connection"
  sensitive   = true
}

variable "asn" {
  type        = number
  description = "The ASN for bgp on the VPN gateway"
  default     = "65516"
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

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "remote_gw_pubip0" {
  type        = string
  description = "Remote peer public IP address 0"
}

variable "remote_gw_pubip1" {
  type        = string
  description = "Remote peer public IP address 1"
}