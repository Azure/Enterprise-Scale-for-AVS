#create a local gateway representing the AVS VWAN gateway
resource "azurerm_local_network_gateway" "this_local_gateway_0" {
  name                = var.local_gateway_name_0
  location            = var.rg_location
  resource_group_name = var.rg_name
  gateway_address     = var.remote_gateway_address_0
  address_space       = ["${var.local_gateway_bgp_ip}/32"]


  bgp_settings {
    asn                 = var.remote_asn
    bgp_peering_address = var.local_gateway_bgp_ip
  }
}

#create the remote connections 
resource "azurerm_virtual_network_gateway_connection" "on_prem_to_avs_hub_0" {
  name                = var.vnet_gateway_connection_name_0
  location            = var.rg_location
  resource_group_name = var.rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = var.virtual_network_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.this_local_gateway_0.id
  enable_bgp                 = true

  shared_key = var.shared_key
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
  module_identifier                       = lower("avs_vpn_create_local_gateways_and_connections_active_active_w_bgp")
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
