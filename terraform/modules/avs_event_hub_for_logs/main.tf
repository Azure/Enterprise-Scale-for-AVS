########################################################################################
#Deploy the Event hub items
########################################################################################
#Deploy the event hub namespace
resource "azurerm_eventhub_namespace" "avs_log_processing" {
  name                = var.eventhub_namespace_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  capacity            = var.eventhub_capacity

  tags = var.tags
}

#deploy the event hub 
resource "azurerm_eventhub" "avs_log_processing" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.avs_log_processing.name
  resource_group_name = var.rg_name
  partition_count     = var.eventhub_partition_count
  message_retention   = var.eventhub_message_retention_days
}

#deploy the authorization rule for the diagnostic setting
resource "azurerm_eventhub_namespace_authorization_rule" "avs_log_processing" {
  name                = var.diagnostic_eventhub_authorization_rule_name
  namespace_name      = azurerm_eventhub_namespace.avs_log_processing.name
  resource_group_name = var.rg_name

  listen = true
  send   = true
  manage = true
}

#deploy the authorization rule for the plugin
resource "azurerm_eventhub_authorization_rule" "avs_log_processing" {
  name                = var.logstash_eventhub_authorization_rule_name
  namespace_name      = azurerm_eventhub_namespace.avs_log_processing.name
  eventhub_name       = azurerm_eventhub.avs_log_processing.name
  resource_group_name = var.rg_name

  listen = true
  send   = true
  manage = true
}

#deploy an eventhub consumer group for use by the logstash plugin
resource "azurerm_eventhub_consumer_group" "avs_log_processing" {
  name                = var.consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.avs_log_processing.name
  eventhub_name       = azurerm_eventhub.avs_log_processing.name
  resource_group_name = var.rg_name
}

#deploy a storage account for use by the eventhub plugin to maintain state
resource "azurerm_storage_account" "avs_log_processing" {
  name                     = var.plugin_storage_account_name
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
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
  module_identifier                       = lower("avs_event_hub_for_logs")
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