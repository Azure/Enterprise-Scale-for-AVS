resource "azurerm_virtual_wan" "vwan" {
  #create a vwan resource indexed with the VWAN name if the exists flag is false
  count = (var.vwan_already_exists ? 0 : 1)

  name                           = var.vwan_name
  resource_group_name            = var.rg_name
  location                       = var.rg_location
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  tags                           = var.tags
}

data "azurerm_virtual_wan" "vwan" {
  name                = var.vwan_name
  resource_group_name = var.rg_name
  depends_on = [
    azurerm_virtual_wan.vwan
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
  module_identifier                       = lower("avs_vwan")
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