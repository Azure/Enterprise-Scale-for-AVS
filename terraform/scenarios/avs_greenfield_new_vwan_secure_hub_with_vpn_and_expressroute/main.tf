# Create local variable derived from an input prefix or modify for customer naming
locals {
  #update naming convention with target naming convention if different
  #resource group names
  private_cloud_rg_name = "${var.prefix}-PrivateCloud-${random_string.namestring.result}"
  network_rg_name       = "${var.prefix}-Network-${random_string.namestring.result}"
  #jumpbox_rg_name       = "${var.prefix}-Jumpbox-${random_string.namestring.result}"

  #AVS specific names
  sddc_name                           = "${var.prefix}-AVS-SDDC-${random_string.namestring.result}"
  expressroute_authorization_key_name = "${var.prefix}-AVS-ExpressrouteAuthKey-${random_string.namestring.result}"
  express_route_connection_name       = "${var.prefix}-AVS-ExpressrouteConnection-${random_string.namestring.result}"

  #VWAN hub and gateway names  
  vwan_name                  = (var.vwan_already_exists ? var.vwan_name : "${var.prefix}-AVS-vwan-${random_string.namestring.result}")
  vwan_hub_name              = "${var.prefix}-AVS-vwan-hub-${random_string.namestring.result}"
  vwan_firewall_policy_name  = "${var.prefix}-AVS-vwan-firewall-policy-${random_string.namestring.result}"
  vwan_firewall_name         = "${var.prefix}-AVS-vwan-firewall-${random_string.namestring.result}"
  vwan_log_analytics_name    = "${var.prefix}-AVS-vwan-firewall-log-analytics-${random_string.namestring.result}"
  express_route_gateway_name = "${var.prefix}-AVS-express-route-gw-${random_string.namestring.result}"
  vpn_gateway_name           = "${var.prefix}-AVS-vpn-gw-${random_string.namestring.result}"

  #service health and monitor names
  action_group_name         = "${var.prefix}-AVS-action-group-${random_string.namestring.result}"
  action_group_shortname    = "avs-sddc-sh1"
  service_health_alert_name = "${var.prefix}-AVS-service-health-alert-${random_string.namestring.result}"

  /*
  #jumpbox and bastion resource names
  jumpbox_spoke_vnet_name            = "${var.prefix}-AVS-vnet-jumpbox-${random_string.namestring.result}"
  jumpbox_spoke_vnet_connection_name = "${var.prefix}-AVS-vnet-connection-jumpbox-${random_string.namestring.result}"
  jumpbox_nic_name                   = "${var.prefix}-AVS-Jumpbox-Nic-${random_string.namestring.result}"
  jumpbox_name                       = "${var.prefix}-js-${random_string.namestring.result}"
  bastion_pip_name                   = "${var.prefix}-AVS-bastion-pip-${random_string.namestring.result}"
  bastion_name                       = "${var.prefix}-AVS-bastion-${random_string.namestring.result}"
  keyvault_name                      = "${var.prefix}-AVS-jump-kv-${random_string.namestring.result}"
*/

  #list of RFC1918 top level summaries for use in VWAN routing
  private_range_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

}

#create a random string for uniqueness during redeployments using the same values
resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

#Create the private cloud resource group
resource "azurerm_resource_group" "greenfield_privatecloud" {
  name     = local.private_cloud_rg_name
  location = var.region
}

resource "azurerm_resource_group" "greenfield_network" {
  name     = local.network_rg_name
  location = var.region
}

module "avs_vwan" {
  source = "../../modules/avs_vwan"

  rg_name             = azurerm_resource_group.greenfield_network.name
  rg_location         = azurerm_resource_group.greenfield_network.location
  vwan_name           = local.vwan_name
  vwan_already_exists = var.vwan_already_exists
  tags                = var.tags
}

#deploy the VWAN hub with the VPN and ExR gateways
module "avs_vwan_hub_with_vpn_and_express_route_gateways" {
  source = "../../modules/avs_vwan_hub_express_route_gateway_and_vpn_gateway"

  rg_name                             = azurerm_resource_group.greenfield_network.name
  rg_location                         = azurerm_resource_group.greenfield_network.location
  vwan_id                             = module.avs_vwan.vwan_id
  vwan_hub_name                       = local.vwan_hub_name
  vwan_hub_address_prefix             = var.vwan_hub_address_prefix
  express_route_gateway_name          = local.express_route_gateway_name
  express_route_connection_name       = local.express_route_connection_name
  express_route_circuit_peering_id    = module.avs_private_cloud.sddc_express_route_private_peering_id
  express_route_authorization_key     = module.avs_private_cloud.sddc_express_route_authorization_key
  express_route_scale_units           = var.express_route_scale_units
  azure_firewall_id                   = module.avs_vwan_azure_firewall_w_policy_and_log_analytics.firewall_id
  all_branch_traffic_through_firewall = var.all_branch_traffic_through_firewall
  vpn_gateway_name                    = local.vpn_gateway_name
  vpn_scale_units                     = var.vpn_scale_units
  tags                                = var.tags
  private_range_prefixes              = local.private_range_prefixes
}

#deploy the private cloud
module "avs_private_cloud" {
  source = "../../modules/avs_private_cloud_single_management_cluster_no_internet_conn"

  sddc_name                           = local.sddc_name
  sddc_sku                            = var.sddc_sku
  management_cluster_size             = var.management_cluster_size
  rg_name                             = azurerm_resource_group.greenfield_privatecloud.name
  rg_location                         = azurerm_resource_group.greenfield_privatecloud.location
  avs_network_cidr                    = var.avs_network_cidr
  expressroute_authorization_key_name = local.expressroute_authorization_key_name
  tags                                = var.tags
}

module "avs_vwan_azure_firewall_w_policy_and_log_analytics" {
  source = "../../modules/avs_vwan_azure_firewall_w_policy_and_log_analytics"

  rg_name                   = azurerm_resource_group.greenfield_network.name
  rg_location               = azurerm_resource_group.greenfield_network.location
  firewall_sku_tier         = var.firewall_sku_tier
  firewall_name             = local.vwan_firewall_name
  log_analytics_name        = local.vwan_log_analytics_name
  vwan_firewall_policy_name = local.vwan_firewall_policy_name
  virtual_hub_id            = module.avs_vwan_hub_with_vpn_and_express_route_gateways.vwan_hub_id
  public_ip_count           = var.hub_firewall_public_ip_count
  tags                      = var.tags
}

module "avs_service_health" {
  source = "../../modules/avs_service_health"

  rg_name                       = azurerm_resource_group.greenfield_privatecloud.name
  action_group_name             = local.action_group_name
  action_group_shortname        = local.action_group_shortname
  email_addresses               = var.email_addresses
  service_health_alert_name     = local.service_health_alert_name
  service_health_alert_scope_id = azurerm_resource_group.greenfield_privatecloud.id
  private_cloud_id              = module.avs_private_cloud.sddc_id
}

/*
##NOTE: The modules below this line are for initial testing and can be removed after the implementation if desired 
#Deploy firewall rules allowing outbound http, https, ntp, and dns
module "outbound_internet_test_firewall_rules" {
  source = "../../modules/avs_azure_firewall_internet_outbound_rules"

  firewall_policy_id  = module.avs_vwan_azure_firewall_w_policy_and_log_analytics.firewall_policy_id
  #avs_ip_ranges       = [var.avs_network_cidr, var.jumpbox_spoke_vnet_address_space[0]]
  private_range_prefixes = local.private_range_prefixes
  has_firewall_policy = true
}

#deploy a new resource group for the jumpbox and bastion components
resource "azurerm_resource_group" "greenfield_jumpbox" {
  name     = local.jumpbox_rg_name
  location = var.region
}

#Deploy a vnet and virtual hub connection for the bastion and jumpbox
module "spoke_vnet_for_jump_and_bastion" {
  source                                 = "../../modules/avs_vwan_vnet_spoke"
  rg_name                                = azurerm_resource_group.greenfield_jumpbox.name
  rg_location                            = azurerm_resource_group.greenfield_jumpbox.location
  vwan_spoke_vnet_name                   = local.jumpbox_spoke_vnet_name
  vwan_spoke_vnet_address_space          = var.jumpbox_spoke_vnet_address_space
  virtual_hub_spoke_vnet_connection_name = local.jumpbox_spoke_vnet_connection_name
  virtual_hub_id                         = module.avs_vwan_hub_with_vpn_and_express_route_gateways.vwan_hub_id
  tags                                   = var.tags
  vwan_spoke_subnets = [
    {
      name           = "JumpboxSubnet",
      address_prefix = var.jumpbox_subnet_prefix
    },
    {
      name           = "AzureBastionSubnet",
      address_prefix = var.bastion_subnet_prefix
    }
  ]
}

#deploy the bastion host
module "avs_bastion" {
  source = "../../modules/avs_bastion_simple"

  bastion_pip_name  = local.bastion_pip_name
  bastion_name      = local.bastion_name
  rg_name           = azurerm_resource_group.greenfield_jumpbox.name
  rg_location       = azurerm_resource_group.greenfield_jumpbox.location
  bastion_subnet_id = module.spoke_vnet_for_jump_and_bastion.subnet_ids["AzureBastionSubnet"].id
  tags              = var.tags
}

#deploy the jumpbox
#deploy the key vault for the jump host
data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

module "avs_keyvault_with_access_policy" {
  source = "../../modules/avs_key_vault"

  #values to create the keyvault
  rg_name                   = azurerm_resource_group.greenfield_jumpbox.name
  rg_location               = azurerm_resource_group.greenfield_jumpbox.location
  keyvault_name             = local.keyvault_name
  azure_ad_tenant_id        = data.azurerm_client_config.current.tenant_id
  #deployment_user_object_id = data.azurerm_client_config.current.object_id
  deployment_user_object_id = data.azuread_client_config.current.object_id #temp fix for az cli breaking change
  tags                      = var.tags
}

#deploy the jumpbox host
module "avs_jumpbox" {
  source = "../../modules/avs_jumpbox"

  jumpbox_nic_name  = local.jumpbox_nic_name
  jumpbox_name      = local.jumpbox_name
  jumpbox_sku       = var.jumpbox_sku
  rg_name           = azurerm_resource_group.greenfield_jumpbox.name
  rg_location       = azurerm_resource_group.greenfield_jumpbox.location
  jumpbox_subnet_id = module.spoke_vnet_for_jump_and_bastion.subnet_ids["JumpboxSubnet"].id
  admin_username    = var.admin_username
  key_vault_id      = module.avs_keyvault_with_access_policy.keyvault_id
  tags              = var.tags

  depends_on = [
    module.avs_keyvault_with_access_policy
  ]
}
*/