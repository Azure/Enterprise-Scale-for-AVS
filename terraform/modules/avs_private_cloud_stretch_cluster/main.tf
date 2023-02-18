terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

data "azurerm_resource_group" "avs" {
  name = var.rg_name
}

#generate a random password to use for the initial NSXT admin account password
resource "random_password" "nsxt" {
  length           = 14
  special          = true
  numeric          = true
  override_special = "%@#"
  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
}

#generate a random password to use for the initial vcenter cloudadmin account password
resource "random_password" "vcenter" {
  length           = 14
  special          = true
  numeric          = true
  override_special = "%@#"
  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
}

#create the private cloud using the azapi resource provider
resource "azapi_resource" "stretch_cluster" {
  type      = "Microsoft.AVS/privateClouds@2022-05-01"
  name      = var.sddc_name
  parent_id = data.azurerm_resource_group.avs.id
  location  = var.rg_location
  tags      = var.tags


  body = jsonencode({
    properties = {
      availability = {
        strategy = "DualZone"
      }

      internet = var.internet_enabled ? "Enabled" : "Disabled"
      managementCluster = {
        clusterSize = var.management_cluster_size
      }

      networkBlock    = var.avs_network_cidr
      nsxtPassword    = random_password.nsxt.result
      vcenterPassword = random_password.vcenter.result
    }
    sku = {
      name = lower(var.sddc_sku)
    }
  })

  response_export_values = ["properties.circuit.expressRouteID", "properties.secondaryCircuit.expressRouteID"]
}

#get the private cloud data for use in creating the auth keys
data "azurerm_vmware_private_cloud" "stretch_cluster" {
  name                = var.sddc_name
  resource_group_name = data.azurerm_resource_group.avs.name

  depends_on = [
    azapi_resource.stretch_cluster
  ]
}

#get the private cloud data using the azapi provider to get the primary and secondary expressROute ID's
data "azapi_resource" "stretch_cluster" {
  name      = "teststretch"
  parent_id = data.azurerm_resource_group.avs.id
  type      = "Microsoft.AVS/privateClouds@2021-12-01"
  response_export_values = [
    "properties.circuit.expressRouteID",
    "properties.circuit.expressRoutePrivatePeeringID",
    "properties.secondaryCircuit.expressRouteID",
    "properties.secondaryCircuit.expressRoutePrivatePeeringID"]

  depends_on = [
    azapi_resource.stretch_cluster
  ]
}

#create the primary zone expressroute auth key
resource "azapi_resource" "authkey_circuit1" {
  type      = "Microsoft.AVS/privateClouds/authorizations@2022-05-01"
  name      = var.expressroute_authorization_key_name_1
  parent_id = data.azurerm_vmware_private_cloud.stretch_cluster.id
  body = jsonencode({
    properties = {
      expressRouteId = jsondecode(azapi_resource.stretch_cluster.output).properties.circuit.expressRouteID
    }
  })
  response_export_values    = ["properties.expressRouteAuthorizationKey"]
  schema_validation_enabled = false
}
#Create the secondary zone expressroute auth key
resource "azapi_resource" "authkey_circuit2" {
  type      = "Microsoft.AVS/privateClouds/authorizations@2022-05-01"
  name      = var.expressroute_authorization_key_name_2
  parent_id = data.azurerm_vmware_private_cloud.stretch_cluster.id
  body = jsonencode({
    properties = {
      expressRouteId = jsondecode(azapi_resource.stretch_cluster.output).properties.secondaryCircuit.expressRouteID
    }
  })
  response_export_values    = ["properties.expressRouteAuthorizationKey"]
  schema_validation_enabled = false
}

#deploy the hcx addon if the hcx_enabled variable is set to true
module "hcx_addon" {
  count  = var.hcx_enabled ? 1 : 0
  source = "../avs_addon_hcx"

  private_cloud_name           = data.azurerm_vmware_private_cloud.stretch_cluster.name
  private_cloud_resource_group = data.azurerm_resource_group.avs.name
  hcx_key_names                = var.hcx_key_names
  module_telemetry_enabled     = false

  depends_on = [
    azapi_resource.stretch_cluster
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
  module_identifier                       = lower("avs_private_cloud_stretch_cluster")
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