locals {
  private_cloud_rg_name               = "${var.prefix}-PrivateCloud-${random_string.namestring.result}"
  sddc_name                           = "${var.prefix}-SDDC-${random_string.namestring.result}"
  expressroute_authorization_key_name = "${var.prefix}-AVS-ExpressrouteAuthKey-${random_string.namestring.result}"
  express_route_connection_name       = "${var.prefix}-AVS-ExpressrouteConnection-${random_string.namestring.result}"
  action_group_name                   = "${var.prefix}-AVS-action-group-${random_string.namestring.result}"
  action_group_shortname              = "avs-sddc-sh"
  service_health_alert_name           = "${var.prefix}-AVS-service-health-alert-${random_string.namestring.result}"
}

#create a random string for uniqueness during redeployments using the same values
resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

#get the existing VWAN hub details
data "azurerm_virtual_hub" "existing" {
  name                = var.vwan_hub_name
  resource_group_name = var.vwan_hub_resource_group_name
}

#create a resource group for the private cloud
resource "azurerm_resource_group" "greenfield_privatecloud" {
  name     = local.private_cloud_rg_name
  location = var.region
}

#create the AVS private cloud
module "avs_private_cloud" {
  source = "../../modules/avs_private_cloud_single_management_cluster_no_internet_conn"

  sddc_name                           = local.sddc_name
  sddc_sku                            = var.sddc_sku
  management_cluster_size             = var.management_cluster_size
  rg_name                             = azurerm_resource_group.greenfield_privatecloud.name
  rg_location                         = azurerm_resource_group.greenfield_privatecloud.location
  avs_network_cidr                    = var.avs_network_cidr
  expressroute_authorization_key_name = local.expressroute_authorization_key_name
  internet_enabled                    = false
  hcx_enabled                         = var.hcx_enabled
  hcx_key_names                       = var.hcx_key_names
  tags                                = var.tags
  module_telemetry_enabled            = false

}

#connect the AVS private cloud to the existing ExpressRoute Gateway in the VWAN hub
resource "azurerm_express_route_connection" "avs_private_cloud_connection" {
  name                             = local.express_route_connection_name
  express_route_gateway_id         = var.express_route_gateway_id
  express_route_circuit_peering_id = module.avs_private_cloud.sddc_express_route_private_peering_id
  authorization_key                = module.avs_private_cloud.sddc_express_route_authorization_key
  enable_internet_security         = var.is_secure_hub #publish a default route to the internet through Azure Firewall when true
}

#deploy service health and azure monitor alerts for AVS
module "avs_service_health" {
  source = "../../modules/avs_service_health"

  rg_name                       = azurerm_resource_group.greenfield_privatecloud.name
  action_group_name             = local.action_group_name
  action_group_shortname        = local.action_group_shortname
  email_addresses               = var.email_addresses
  service_health_alert_name     = local.service_health_alert_name
  service_health_alert_scope_id = azurerm_resource_group.greenfield_privatecloud.id
  private_cloud_id              = module.avs_private_cloud.sddc_id
  module_telemetry_enabled      = false
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
  module_identifier                       = lower("avs_brownfield_existing_vwan_hub")
  telem_arm_deployment_name               = "d8a06ade-2654-4a78-99da-e941f87a3a2a.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
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
  location         = azurerm_resource_group.greenfield_privatecloud.location
  template_content = local.telem_arm_subscription_template_content
}