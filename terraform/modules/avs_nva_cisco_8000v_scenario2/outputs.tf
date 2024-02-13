output "csr0_fw_facing_ip" {
  value = azurerm_network_interface.node0_csr_nic0.private_ip_address
}

output "csr0_avs_facing_ip" {
  value = azurerm_network_interface.node0_csr_nic1.private_ip_address
}

output "csr1_fw_facing_ip" {
  value = azurerm_network_interface.node1_csr_nic0.private_ip_address
}

output "csr1_avs_facing_ip" {
  value = azurerm_network_interface.node1_csr_nic1.private_ip_address
}

output "asn" {
  value = var.asn
}

output "config_file" {
  value = data.template_file.node_config.rendered
}

