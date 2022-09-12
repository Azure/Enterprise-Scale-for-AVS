output "sddc_id" {
  value = azurerm_vmware_private_cloud.privatecloud.id
}

output "sddc_express_route_id" {
  value = azurerm_vmware_private_cloud.privatecloud.circuit[0].express_route_id
}

output "sddc_express_route_authorization_key" {
  value = azurerm_vmware_express_route_authorization.expressrouteauthkey.express_route_authorization_key
}

output "sddc_express_route_private_peering_id" {
  value = azurerm_vmware_private_cloud.privatecloud.circuit[0].express_route_private_peering_id
}

output "sddc_vcsa_endpoint" {
  value = azurerm_vmware_private_cloud.privatecloud.vcsa_endpoint
}

output "sddc_nsxt_manager_endpoint" {
  value = azurerm_vmware_private_cloud.privatecloud.nsxt_manager_endpoint
}

output "sddc_hcx_cloud_manager_endpoint" {
  value = azurerm_vmware_private_cloud.privatecloud.hcx_cloud_manager_endpoint
}

output "sddc_provisioning_subnet_cidr" {
  value = azurerm_vmware_private_cloud.privatecloud.provisioning_subnet_cidr
}

