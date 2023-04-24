output "routeserver_id" {
  value = azurerm_virtual_hub_ip.routeserver.id
}

output "routeserver_details" {
  value = azurerm_virtual_hub.virtual_hub
}

output "virtual_hub_id" {
  value = azurerm_virtual_hub.virtual_hub.id
}