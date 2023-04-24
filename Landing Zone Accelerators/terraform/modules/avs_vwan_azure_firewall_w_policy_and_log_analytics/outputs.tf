output "firewall_id" {
  value = azurerm_firewall.firewall.id
}

output "firewall_private_ip_address" {
  value = azurerm_firewall.firewall.virtual_hub[0].private_ip_address
}

output "firewall_name" {
  value = azurerm_firewall.firewall.name
}

output "firewall_public_ip" {
  value = azurerm_firewall.firewall.virtual_hub[0].public_ip_addresses
}

output "firewall_policy_id" {
  value = azurerm_firewall_policy.avs_base_policy.id
}