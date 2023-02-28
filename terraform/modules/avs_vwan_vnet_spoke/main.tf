#create a vnet with single subnet
resource "azurerm_virtual_network" "vwan_spoke_vnet" {
  name                = var.vwan_spoke_vnet_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.vwan_spoke_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "vwan_spoke_subnet" {
  for_each             = { for subnet in var.vwan_spoke_subnets : subnet.name => subnet }
  name                 = each.value.name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vwan_spoke_vnet.name
  address_prefixes     = each.value.address_prefix
}

#create a vnet connection to the vwan hub
resource "azurerm_virtual_hub_connection" "vwan_spoke_connection" {
  name                      = var.virtual_hub_spoke_vnet_connection_name
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.vwan_spoke_vnet.id
  internet_security_enabled = true
}

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
  module_identifier                       = lower("avs_vwan_vnet_spoke")
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
  location         = var.rg_location
  template_content = local.telem_arm_subscription_template_content
}