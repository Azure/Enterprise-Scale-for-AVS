output "jumpbox_id" {
  value = azurerm_windows_virtual_machine.vm.id
}

output "jumpbox_private_ip_address" {
  value = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "jumpbox_managed_identity" {
  value = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}