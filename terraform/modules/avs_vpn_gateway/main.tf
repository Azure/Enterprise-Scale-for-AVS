resource "azurerm_public_ip" "gatewaypip_1" {
  name                = var.vpn_pip_name_1
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_public_ip" "gatewaypip_2" {
  name                = var.vpn_pip_name_2
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = var.vpn_gateway_name
  resource_group_name = var.rg_name
  location            = var.rg_location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = var.vpn_gateway_sku
  generation = "Generation2"

  active_active = true
  enable_bgp    = true

  bgp_settings {
    asn = var.asn
  }


  ip_configuration {
    name                          = "${var.vpn_gateway_name}_active_1"
    public_ip_address_id          = azurerm_public_ip.gatewaypip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  ip_configuration {
    name                          = "${var.vpn_gateway_name}_active_2"
    public_ip_address_id          = azurerm_public_ip.gatewaypip_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
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
  module_identifier                       = lower("avs_vpn_gateway")
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