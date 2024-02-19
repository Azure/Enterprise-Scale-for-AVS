output "firewall_id" {
  value = azurerm_firewall.firewall.id
}

output "firewall_private_ip_address" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "firewall_name" {
  value = azurerm_firewall.firewall.name
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_pip.ip_address
}

output "firewall_policy_name" {
  value = var.firewall_policy_name
}

output "firewall_policy_id" {
  value = azurerm_firewall_policy.avs_base_policy.id
}

output "firewall_rg_name" {
  value = var.rg_name
}