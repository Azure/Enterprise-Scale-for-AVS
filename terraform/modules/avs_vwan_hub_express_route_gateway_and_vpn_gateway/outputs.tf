

output "vwan_hub_id" {
  value = azurerm_virtual_hub.vwan_hub.id
}

output "express_route_gateway_id" {
  value = azurerm_express_route_gateway.vwan_express_route_gateway.id
}

output "vpn_gateway_id" {
  value = azurerm_vpn_gateway.vwan_vpn_gateway.id
}

output "vpn_bgp_settings" {
  value = azurerm_vpn_gateway.vwan_vpn_gateway.bgp_settings
}

output "default_route_table_id" {
  value = azurerm_virtual_hub.vwan_hub.default_route_table_id
}

output "virtual_router_ips" {
  value = azurerm_virtual_hub.vwan_hub.virtual_router_ips
}