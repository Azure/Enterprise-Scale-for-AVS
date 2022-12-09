locals {
  #jumpbox and bastion resource names  
  jumpbox_rg_name                    = "${var.prefix}-Jumpbox-${random_string.namestring.result}"
  jumpbox_spoke_vnet_name            = "${var.prefix}-AVS-vnet-jumpbox-${random_string.namestring.result}"
  jumpbox_spoke_vnet_connection_name = "${var.prefix}-AVS-vnet-connection-jumpbox-${random_string.namestring.result}"
  jumpbox_nic_name                   = "${var.prefix}-AVS-Jumpbox-Nic-${random_string.namestring.result}"
  jumpbox_name                       = "${var.prefix}-js${random_string.namestring.result}"
  bastion_pip_name                   = "${var.prefix}-AVS-bastion-pip-${random_string.namestring.result}"
  bastion_name                       = "${var.prefix}-AVS-bastion-${random_string.namestring.result}"
  keyvault_name                      = "${var.prefix}-jump-kv-${random_string.namestring.result}"
  subnets = [
    {
      name           = "AzureBastionSubnet",
      address_prefix = [var.bastion_subnet_prefix]
    },
    {
      name           = "JumpBoxSubnet"
      address_prefix = [var.jumpbox_subnet_prefix]
    }
  ]
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

#create spoke vnet
#deploy a new resource group for the jumpbox and bastion components
resource "azurerm_resource_group" "greenfield_jumpbox" {
  name     = local.jumpbox_rg_name
  location = var.region
}

module "spoke_vnet_for_jump_and_bastion" {
  source = "../../modules/avs_vnet_variable_subnets"

  rg_name                  = azurerm_resource_group.greenfield_jumpbox.name
  rg_location              = azurerm_resource_group.greenfield_jumpbox.location
  vnet_name                = local.jumpbox_spoke_vnet_name
  vnet_address_space       = var.jumpbox_spoke_vnet_address_space
  subnets                  = local.subnets
  tags                     = var.tags
  module_telemetry_enabled = false
}

#create jump and bastion
module "avs_bastion" {
  source = "../../modules/avs_bastion_simple"

  bastion_pip_name         = local.bastion_pip_name
  bastion_name             = local.bastion_name
  rg_name                  = azurerm_resource_group.greenfield_jumpbox.name
  rg_location              = azurerm_resource_group.greenfield_jumpbox.location
  bastion_subnet_id        = module.spoke_vnet_for_jump_and_bastion.subnet_ids["AzureBastionSubnet"].id
  tags                     = var.tags
  module_telemetry_enabled = false
}

#if vwan - create vwan vnet connection
data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

module "avs_keyvault_with_access_policy" {
  source = "../../modules/avs_key_vault"

  #values to create the keyvault
  rg_name                   = azurerm_resource_group.greenfield_jumpbox.name
  rg_location               = azurerm_resource_group.greenfield_jumpbox.location
  keyvault_name             = local.keyvault_name
  azure_ad_tenant_id        = data.azurerm_client_config.current.tenant_id
  deployment_user_object_id = data.azuread_client_config.current.object_id
  tags                      = var.tags
  module_telemetry_enabled  = false
}

#deploy the jumpbox host
module "avs_jumpbox" {
  source = "../../modules/avs_jumpbox"

  jumpbox_nic_name         = local.jumpbox_nic_name
  jumpbox_name             = local.jumpbox_name
  jumpbox_sku              = var.jumpbox_sku
  rg_name                  = azurerm_resource_group.greenfield_jumpbox.name
  rg_location              = azurerm_resource_group.greenfield_jumpbox.location
  jumpbox_subnet_id        = module.spoke_vnet_for_jump_and_bastion.subnet_ids["JumpBoxSubnet"].id
  admin_username           = var.admin_username
  key_vault_id             = module.avs_keyvault_with_access_policy.keyvault_id
  tags                     = var.tags
  module_telemetry_enabled = false

  depends_on = [
    module.avs_keyvault_with_access_policy
  ]
}

#get the hub vnet information.  Assumes hub is in the same subscription as the test spoke 
#TODO: Update this module to allow for the hub components to exist in a different subscription
data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_rg_name
}

#if not vwan - create vnet peer
resource "azurerm_virtual_network_peering" "hub_owned_peer" {
  name                      = "${local.jumpbox_spoke_vnet_name}-link"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = module.spoke_vnet_for_jump_and_bastion.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_owned_peer" {
  name                      = "${var.hub_vnet_name}-link"
  resource_group_name       = azurerm_resource_group.greenfield_jumpbox.name
  virtual_network_name      = module.spoke_vnet_for_jump_and_bastion.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}
#TODO: If firewall add UDR

#############################################################################################
# Telemetry Section - Toggled on and off with the telemetry variable
# This allows us to get deployment frequency statistics for deployments
# Re-using parts of the Core Enterprise Landing Zone methodology
#############################################################################################
locals {
  #create an empty ARM template to use for generating the deployment value
  telem_arm_subscription_template_content = <<TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {},
      "variables": {},
      "resources": [],
      "outputs": {
        "telemetry": {
          "type": "String",
          "value": "For more information, see https://aka.ms/alz/tf/telemetry"
        }
      }
    }
    TEMPLATE
  module_identifier                       = lower("avs_test_spoke_with_jump_vm")
  telem_arm_deployment_name               = "${lower(var.guid_telemetry)}.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = var.module_telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  location         = azurerm_resource_group.greenfield_jumpbox.location
  template_content = local.telem_arm_subscription_template_content
}