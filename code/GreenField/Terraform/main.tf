# Configure the minimum required providers supported by this module

data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>1.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  partner_id = "754599a0-0a6f-424a-b4c5-1b12be198ae8"
}

## Optional settings to setup a terraform backend in Azure storage

# terraform {
#     backend "azurerm" {
#         resource_group_name = "replace me"   
#         storage_account_name = "replace me"
#         container_name = "replace me"
#         key = "terraform.tfstate"
#     }
# }

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
  module_identifier                       = lower("avs_greenfield_standard")
  telem_arm_deployment_name               = "754599a0-0a6f-424a-b4c5-1b12be198ae8.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = var.telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  provider         = azurerm
  location         = azurerm_vmware_private_cloud.privatecloud.location
  template_content = local.telem_arm_subscription_template_content
}