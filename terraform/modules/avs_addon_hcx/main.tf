#get the existing private cloud details
data "azurerm_vmware_private_cloud" "hcx_private_cloud" {
  name                = var.private_cloud_name
  resource_group_name = var.private_cloud_resource_group
}

#deploy the hcx addon
resource "azapi_resource" "hcx_addon" {
  type = "Microsoft.AVS/privateClouds/addons@2022-05-01"
  #Resource Name must match the addonType
  name      = "HCX"
  parent_id = data.azurerm_vmware_private_cloud.hcx_private_cloud.id
  body = jsonencode({
    properties = {
      addonType = "HCX"
      offer     = "VMware MaaS Cloud Provider"
    }
  })

  #adding lifecycle block to handle replacement issue with parent_id
  lifecycle {
    ignore_changes = [
      parent_id
    ]
  }
}

#adding sleep wait to handle lag in hcx registration for keys
resource "time_sleep" "wait_120_seconds" {
  depends_on = [azapi_resource.hcx_addon]

  create_duration = "120s"
}

#create the hcx key(s)
resource "azapi_resource" "hcx_keys" {
  for_each = toset(var.hcx_key_names)

  type                   = "Microsoft.AVS/privateClouds/hcxEnterpriseSites@2022-05-01"
  name                   = each.key
  parent_id              = data.azurerm_vmware_private_cloud.hcx_private_cloud.id
  response_export_values = ["*"]

  depends_on = [
    time_sleep.wait_120_seconds,
    azapi_resource.hcx_addon
  ]

  lifecycle {
    ignore_changes = [
      parent_id
    ]
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
  module_identifier                       = lower("avs_addon_hcx")
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
  location         = data.azurerm_vmware_private_cloud.hcx_private_cloud.location
  template_content = local.telem_arm_subscription_template_content
}
