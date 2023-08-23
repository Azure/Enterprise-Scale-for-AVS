locals {
  expressroute_authorization_key_name = "${var.expressroute_authorization_key_prefix}-auth-key"
  express_route_connection_name       = "${var.expressroute_authorization_key_prefix}-connection"
  hcx_key_names                       = ["${var.hcx_key_prefix}-hcx-key-001", "${var.hcx_key_prefix}-hcx-key-002"]
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

#Ensure the resource provider is properly registered
#resource "azurerm_resource_provider_registration" "AVS" {
#  name = "Microsoft.AVS"
#}

#create the initial private cloud with the VWAN internet connection disabled
#override the create timeout to address issues with the API retry limits and long-running deployments
resource "azurerm_vmware_private_cloud" "privatecloud" {
  name                = var.sddc_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku_name            = lower(var.sddc_sku)
  tags                = var.tags

  management_cluster {
    size = var.management_cluster_size
  }

  network_subnet_cidr         = var.avs_network_cidr
  internet_connection_enabled = var.internet_enabled
  nsxt_password               = random_password.nsxt.result
  vcenter_password            = random_password.vcenter.result

  timeouts {
    create = "20h"
  }

  lifecycle {
    ignore_changes = [
      nsxt_password,
      vcenter_password
    ]
  }

  #depends_on = [
  #  azurerm_resource_provider_registration.AVS
  #]
}

#deploy the hcx addon if the hcx_enabled variable is set to true
module "hcx_addon" {
  count  = var.hcx_enabled ? 1 : 0
  source = "../avs_addon_hcx"

  private_cloud_name           = azurerm_vmware_private_cloud.privatecloud.name
  private_cloud_resource_group = var.rg_name
  hcx_key_names                = local.hcx_key_names
  module_telemetry_enabled     = false

  depends_on = [
    azurerm_vmware_private_cloud.privatecloud
  ]
}

#Generate an expressRoute authorization key for connection to Azure
resource "azurerm_vmware_express_route_authorization" "expressrouteauthkey" {
  count            = var.attach_to_expressroute_gateway ? 1 : 0
  name             = local.expressroute_authorization_key_name
  private_cloud_id = azurerm_vmware_private_cloud.privatecloud.id
}


resource "azurerm_virtual_network_gateway_connection" "avs" {
  count               = var.attach_to_expressroute_gateway ? 1 : 0
  name                = local.express_route_connection_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  enable_bgp          = true

  type                       = "ExpressRoute"
  virtual_network_gateway_id = var.expressroute_gateway_id
  express_route_circuit_id   = azurerm_vmware_private_cloud.privatecloud.circuit[0].express_route_id
  authorization_key          = azurerm_vmware_express_route_authorization.expressrouteauthkey[0].express_route_authorization_key
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
  module_identifier                       = lower("avs_private_cloud_single_management_cluster_no_internet_conn")
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
  location         = azurerm_vmware_private_cloud.privatecloud.location
  template_content = local.telem_arm_subscription_template_content
}