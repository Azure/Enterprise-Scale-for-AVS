terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

resource "azurerm_virtual_hub" "virtual_hub" {
  name                = var.virtual_hub_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = "Standard"
}

resource "azurerm_public_ip" "routeserver_pip" {
  name                = var.virtual_hub_pip_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_hub_ip" "routeserver" {
  name                         = var.route_server_name
  virtual_hub_id               = azurerm_virtual_hub.virtual_hub.id
  private_ip_allocation_method = "Dynamic"
  public_ip_address_id         = azurerm_public_ip.routeserver_pip.id
  subnet_id                    = var.route_server_subnet_id
}

resource "azapi_update_resource" "routeserver_branch_to_branch" {
  type        = "Microsoft.Network/virtualHubs@2021-05-01"
  resource_id = azurerm_virtual_hub.virtual_hub.id

  body = jsonencode({
    properties = {
      allowBranchToBranchTraffic = true
    }
  })

  depends_on = [
    azurerm_public_ip.routeserver_pip,
    azurerm_virtual_hub_ip.routeserver
  ]
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
  module_identifier                       = lower("avs_routeserver")
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