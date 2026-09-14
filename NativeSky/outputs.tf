/*
output "resource_group_id" {
  description = "The resource ID of the resource group."
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.name
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault containing generated VM administrator passwords."
  value       = module.key_vault.resource_id
}

output "key_vault_name" {
  description = "The name of the Key Vault containing generated VM administrator passwords."
  value       = module.key_vault.name
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace receiving diagnostic logs and metrics."
  value       = module.log_analytics_workspace.resource_id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace receiving diagnostic logs and metrics."
  value       = var.log_analytics_workspace_name
}

output "virtual_wan_id" {
  description = "The resource ID of the Virtual WAN."
  value       = module.virtual_wan.resource_id
}

output "virtual_wan_name" {
  description = "The name of the Virtual WAN."
  value       = module.virtual_wan.name
}

output "virtual_hub_id" {
  description = "The resource ID of the Virtual Hub."
  value       = module.virtual_wan.virtual_hub_resource_ids["primary"]
}

output "virtual_hub_name" {
  description = "The name of the Virtual Hub."
  value       = module.virtual_wan.virtual_hub_resource_names["primary"]
}

output "bastion_id" {
  description = "The resource ID of the Azure Bastion host."
  value       = azurerm_bastion_host.this.id
}

output "bastion_name" {
  description = "The name of the Azure Bastion host."
  value       = azurerm_bastion_host.this.name
}

output "bastion_virtual_network_id" {
  description = "The resource ID of the dedicated Bastion virtual network."
  value       = azurerm_virtual_network.bastion.id
}

output "bastion_subnet_id" {
  description = "The resource ID of AzureBastionSubnet."
  value       = azurerm_subnet.bastion.id
}

output "bastion_public_ip_address" {
  description = "The public IPv4 address assigned to the Azure Bastion host."
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_to_target_peering_ids" {
  description = "A map of Bastion-to-target VNet peering resource IDs keyed by target_vnets map key."
  value       = { for key, peering in azurerm_virtual_network_peering.bastion_to_target : key => peering.id }
}

output "target_to_bastion_peering_ids" {
  description = "A map of target-to-Bastion VNet peering resource IDs keyed by target_vnets map key."
  value       = { for key, peering in azurerm_virtual_network_peering.target_to_bastion : key => peering.id }
}

output "target_vnet_ids" {
  description = "A map of target VNet resource IDs keyed by target_vnets map key."
  value       = { for key, vnet in module.target_vnets : key => vnet.resource_id }
}

output "target_vnet_names" {
  description = "A map of target VNet names keyed by target_vnets map key."
  value       = { for key, vnet in module.target_vnets : key => vnet.name }
}

output "target_vnet_subnets" {
  description = "A map of target VNet subnet outputs keyed by target_vnets map key."
  value       = { for key, vnet in module.target_vnets : key => vnet.subnets }
}

output "target_vnet_hub_connection_names" {
  description = "A map of Virtual Hub connection names keyed by target_vnets map key."
  value = {
    for key, vnet in module.target_vnets : key => coalesce(
      var.target_vnets[key].virtual_hub_connection.name,
      "vhub-conn-${vnet.name}"
    )
  }
}

output "appliance_nat_gateway_ids" {
  description = "A map of appliance subnet NAT Gateway resource IDs keyed by target_vnets map key."
  value       = { for key, nat_gateway in azurerm_nat_gateway.appliance : key => nat_gateway.id }
}

output "appliance_nat_gateway_public_ip_ids" {
  description = "A map of appliance NAT Gateway public IP resource IDs keyed by target_vnets map key."
  value       = { for key, public_ip in azurerm_public_ip.appliance_nat_gateway : key => public_ip.id }
}

output "appliance_nat_gateway_public_ip_addresses" {
  description = "A map of appliance NAT Gateway public IPv4 addresses keyed by target_vnets map key."
  value       = { for key, public_ip in azurerm_public_ip.appliance_nat_gateway : key => public_ip.ip_address }
}

output "appliance_subnet_nat_gateway_association_ids" {
  description = "A map of appliance subnet NAT Gateway association IDs keyed by target_vnets map key."
  value       = { for key, vnet in module.target_vnets : key => vnet.subnets["l2_appliance"].resource_id }
}

output "target_virtual_machine_ids" {
  description = "A map of virtual machine resource IDs keyed by target_vnets map key."
  value       = { for key, virtual_machine in module.target_vnet_virtual_machines : key => virtual_machine.resource_id }
}

output "target_virtual_machine_names" {
  description = "A map of virtual machine names keyed by target_vnets map key."
  value       = { for key, virtual_machine in module.target_vnet_virtual_machines : key => virtual_machine.name }
}

output "target_virtual_machine_network_interfaces" {
  description = "A map of virtual machine network interface outputs keyed by target_vnets map key."
  value       = { for key, virtual_machine in module.target_vnet_virtual_machines : key => virtual_machine.network_interfaces }
}

output "target_virtual_machine_data_collection_rule_ids" {
  description = "A map of Azure Monitor data collection rule resource IDs keyed by target_vnets map key."
  value       = { for key, rule in azurerm_monitor_data_collection_rule.linux_vm : key => rule.id }
}

output "target_virtual_machine_data_collection_rule_association_ids" {
  description = "A map of Azure Monitor data collection rule association IDs keyed by target_vnets map key."
  value       = { for key, association in azurerm_monitor_data_collection_rule_association.linux_vm : key => association.id }
}

output "target_load_balancer_ids" {
  description = "A map of internal Load Balancer resource IDs keyed by target_vnets map key."
  value       = { for key, load_balancer in module.target_vnet_load_balancers : key => load_balancer.resource_id }
}

output "target_load_balancer_frontend_ip_configurations" {
  description = "A map of internal Load Balancer frontend IP configurations keyed by target_vnets map key."
  value       = { for key, load_balancer in module.target_vnet_load_balancers : key => load_balancer.azurerm_lb.frontend_ip_configuration }
}

output "target_load_balancer_backend_pools" {
  description = "A map of internal Load Balancer backend pools keyed by target_vnets map key."
  value       = { for key, load_balancer in module.target_vnet_load_balancers : key => load_balancer.azurerm_lb_backend_address_pool }
}

output "target_subnet_route_table_ids" {
  description = "A map of route table resource IDs keyed by target VNet and subnet as <vnet_key>.<subnet_key>."
  value       = { for key, route_table in module.target_subnet_route_tables : key => route_table.resource_id }
}

output "target_subnet_routes" {
  description = "A map of route outputs keyed by target VNet and subnet as <vnet_key>.<subnet_key>."
  value       = { for key, route_table in module.target_subnet_route_tables : key => route_table.routes }
}

output "avs_connection_generation" {
  description = "The configured AVS private cloud generation, or null when no AVS connection is configured."
  value       = var.avs_private_cloud_connection == null ? null : lower(var.avs_private_cloud_connection.generation)
}

output "avs_expressroute_gateway_id" {
  description = "The AVS Gen1 Virtual Hub ExpressRoute gateway resource ID, or null for Gen2 and disabled connections."
  value       = try(module.virtual_wan.ergw_resource_ids_by_hub_key["primary"], null)
}

*/