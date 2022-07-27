output "vwan_id" {
  value = module.avs_vwan.vwan_id
}

output "vwan_hub_id" {
  value = module.avs_vwan_hub_with_vpn_and_express_route_gateways.vwan_hub_id
}

output "express_route_gateway_id" {
  value = module.avs_vwan_hub_with_vpn_and_express_route_gateways.express_route_gateway_id
}

output "vpn_gateway_id" {
  value = module.avs_vwan_hub_with_vpn_and_express_route_gateways.vpn_gateway_id
}

output "vpn_bgp_settings" {
  value = module.avs_vwan_hub_with_vpn_and_express_route_gateways.vpn_bgp_settings
}

output "network_resource_group_name" {
  value = azurerm_resource_group.greenfield_network.name
}

output "network_resource_group_location" {
  value = azurerm_resource_group.greenfield_network.location
}

output "firewall_policy_id" {
  value = module.avs_vwan_azure_firewall_w_policy_and_log_analytics.firewall_policy_id
}