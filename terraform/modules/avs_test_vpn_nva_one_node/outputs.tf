output "key_vault_id" {
  value = module.on_prem_keyvault_with_access_policy.keyvault_id
}

output "csr_pip_0" {
  value = module.csr_vpn_appliance.public_ip_address
}

output "bgp_peer_ip_0" {
  value = cidrhost(var.csr_tunnel_cidr, 1)
}

output "bgp_peer_ip_1" {
  value = cidrhost(var.csr_tunnel_cidr, 2)
}

output "asn" {
  value = var.asn
}

output "csr_bgp_ip" {
  value = var.csr_bgp_ip
}

output "csr_config" {
  value = module.csr_vpn_appliance.csr_config
}