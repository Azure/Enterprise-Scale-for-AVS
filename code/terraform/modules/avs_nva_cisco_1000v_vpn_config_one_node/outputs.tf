output "private_ip_address" {
  value = azurerm_network_interface.node0_csr_nic0.private_ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.gatewaypip_1.ip_address
}

output "csr_config" {
  value = data.template_file.node_config.rendered
}