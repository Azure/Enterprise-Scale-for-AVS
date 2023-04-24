output "sddc_id" {
  value = data.azapi_resource.stretch_cluster.id
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
  value = jsondecode(data.azapi_resource.stretch_cluster.output).properties.endpoints.vcsa
}

output "sddc_nsxt_manager_endpoint" {
  value = jsondecode(data.azapi_resource.stretch_cluster.output).properties.endpoints.nsxtManager
}

output "sddc_hcx_cloud_manager_endpoint" {
  value = jsondecode(data.azapi_resource.stretch_cluster.output).properties.endpoints.hcxCloudManager
}

output "sddc_provisioning_subnet_cidr" {
  value = jsondecode(data.azapi_resource.stretch_cluster.output).properties.provisioningNetwork
}

/*
#return the hcx keys if hcx is enabled, empty map if not.  
#output will referenced using an index due to count on module.
output "hcx_keys" {
  value = module.hcx_addon[*].keys
}
*/
output "full_cluster_details" {
  value = data.azapi_resource.stretch_cluster
}