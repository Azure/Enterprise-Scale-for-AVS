output "sddc_id" {
  value = data.azurerm_vmware_private_cloud.stretch_cluster.id
}

output "sddc_express_route_id" {
  value = [
    jsondecode(data.azapi_resource.stretch_cluster.output).properties.circuit.expressRouteID,
    jsondecode(data.azapi_resource.stretch_cluster.output).properties.secondaryCircuit.expressRouteID
  ]
}

output "sddc_express_route_authorization_key" {
  value = [
    jsondecode(azapi_resource.authkey_circuit1.output).properties.expressRouteAuthorizationKey,
    jsondecode(azapi_resource.authkey_circuit2.output).properties.expressRouteAuthorizationKey
  ]
}

output "sddc_express_route_private_peering_id" {
  value = [
    jsondecode(data.azapi_resource.stretch_cluster.output).properties.circuit.expressRoutePrivatePeeringID,
    jsondecode(data.azapi_resource.stretch_cluster.output).properties.secondaryCircuit.expressRoutePrivatePeeringID
  ]
}

output "sddc_vcsa_endpoint" {
  value = data.azurerm_vmware_private_cloud.stretch_cluster.vcsa_endpoint
}

output "sddc_nsxt_manager_endpoint" {
  value = data.azurerm_vmware_private_cloud.stretch_cluster.nsxt_manager_endpoint
}

output "sddc_hcx_cloud_manager_endpoint" {
  value = data.azurerm_vmware_private_cloud.stretch_cluster.hcx_cloud_manager_endpoint
}

output "sddc_provisioning_subnet_cidr" {
  value = data.azurerm_vmware_private_cloud.stretch_cluster.provisioning_subnet_cidr
}

#return the hcx keys if hcx is enabled, empty map if not.  
#output will referenced using an index due to count on module.
output "hcx_keys" {
  value = module.hcx_addon[*].keys
}