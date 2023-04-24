# Create local variable derived from an input prefix or modify for customer naming
locals {
  #update naming convention with target naming convention if different
  private_cloud_rg_name                 = "${var.prefix}-PrivateCloud-${random_string.namestring.result}"
  network_rg_name                       = "${var.prefix}-Network-${random_string.namestring.result}"
  sddc_name                             = "${var.prefix}-AVS-SDDC-${random_string.namestring.result}"
  expressroute_authorization_key_name_1 = "${var.prefix}-AVS-ExpressrouteAuthKey-1-${random_string.namestring.result}"
  expressroute_authorization_key_name_2 = "${var.prefix}-AVS-ExpressrouteAuthKey-2-${random_string.namestring.result}"
  express_route_connection_name_1       = "${var.prefix}-AVS-ExpressrouteConnection-1-${random_string.namestring.result}"
  express_route_connection_name_2       = "${var.prefix}-AVS-ExpressrouteConnection-2-${random_string.namestring.result}"


  service_health_alert_name = "${var.prefix}-AVS-service-health-alert-${random_string.namestring.result}"
  action_group_name         = "${var.prefix}-AVS-action-group-${random_string.namestring.result}"
  action_group_shortname    = "avs-sddc-sh"
}


#create a random string for uniqueness during redeployments using the same values
resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

#Create the private cloud resource group
resource "azurerm_resource_group" "greenfield_privatecloud" {
  name     = local.private_cloud_rg_name
  location = var.region
}

#deploy a private cloud with a single management cluster and connect to the expressroute gateway
module "avs_private_cloud" {
  source = "../../modules/avs_private_cloud_stretch_cluster"

  sddc_name                             = local.sddc_name
  sddc_sku                              = var.sddc_sku
  management_cluster_size               = var.management_cluster_size
  rg_name                               = azurerm_resource_group.greenfield_privatecloud.name
  rg_location                           = azurerm_resource_group.greenfield_privatecloud.location
  avs_network_cidr                      = var.avs_network_cidr
  expressroute_authorization_key_name_1 = local.expressroute_authorization_key_name_1
  expressroute_authorization_key_name_2 = local.expressroute_authorization_key_name_2
  internet_enabled                      = var.internet_enabled
  hcx_enabled                           = var.hcx_enabled
  hcx_key_names                         = var.hcx_key_names
  tags                                  = var.tags
  module_telemetry_enabled              = false
}

#deploy the default service health and azure monitor alerts
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

resource "azurerm_virtual_network_gateway_connection" "avs_1" {
  name                = local.express_route_connection_name_1
  location            = azurerm_resource_group.greenfield_privatecloud.location
  resource_group_name = azurerm_resource_group.greenfield_privatecloud.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = var.expressroute_gateway_id
  express_route_circuit_id   = module.avs_private_cloud.sddc_express_route_id[0]
  authorization_key          = module.avs_private_cloud.sddc_express_route_authorization_key[0]
}

resource "azurerm_virtual_network_gateway_connection" "avs_2" {
  name                = local.express_route_connection_name_2
  location            = azurerm_resource_group.greenfield_privatecloud.location
  resource_group_name = azurerm_resource_group.greenfield_privatecloud.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = var.expressroute_gateway_id
  express_route_circuit_id   = module.avs_private_cloud.sddc_express_route_id[1]
  authorization_key          = module.avs_private_cloud.sddc_express_route_authorization_key[1]
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
  module_identifier                       = lower("avs_greenfield_stretch_cluster_existing_exr_gateway")
  telem_arm_deployment_name               = "fd6adce1-fd57-4849-8675-f2164bdbb099.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
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