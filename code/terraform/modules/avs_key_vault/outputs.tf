#export the keyvault id
output "keyvault_id" {
  value = azurerm_key_vault.infra_vault.id
}