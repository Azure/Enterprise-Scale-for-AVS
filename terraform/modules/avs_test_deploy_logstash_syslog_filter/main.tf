#create the resource group for all of the log processing items
resource "azurerm_resource_group" "avs_log_processing" {
  name     = var.rg_name
  location = var.rg_location
}

#create the event hub artifacts
module "create_event_hub_resources" {
  source = "../../modules/avs_event_hub_for_logs"

  rg_name                                     = azurerm_resource_group.avs_log_processing.name
  rg_location                                 = azurerm_resource_group.avs_log_processing.location
  eventhub_namespace_name                     = var.eventhub_namespace_name
  eventhub_capacity                           = var.eventhub_capacity
  eventhub_name                               = var.eventhub_name
  eventhub_partition_count                    = var.eventhub_partition_count
  eventhub_message_retention_days             = var.eventhub_message_retention_days
  diagnostic_eventhub_authorization_rule_name = var.diagnostic_eventhub_authorization_rule_name
  logstash_eventhub_authorization_rule_name   = var.logstash_eventhub_authorization_rule_name
  consumer_group_name                         = var.consumer_group_name
  plugin_storage_account_name                 = var.plugin_storage_account_name
  tags                                        = var.tags
}

#create a logging application and service principal
module "create_logging_service_principal" {
  source                                    = "../../modules/avs_log_filtering_accounts"
  avs_log_processing_service_principal_name = var.avs_log_processing_service_principal_name
}

#create the log analytics workspace, dCE and DCR resources
module "create_log_analytics_resources" {
  source = "../../modules/avs_log_analytics_w_custom_syslog"

  rg_name                            = azurerm_resource_group.avs_log_processing.name
  rg_location                        = azurerm_resource_group.avs_log_processing.location
  tags                               = var.tags
  log_analytics_name                 = var.log_analytics_name
  custom_table_name                  = var.custom_table_name
  data_collection_endpoint_name      = var.data_collection_endpoint_name
  data_collection_rule_name          = var.data_collection_rule_name
  log_processing_principal_object_id = module.create_logging_service_principal.logging_object_id
}

#create a keyvault and access policy
#deploy the key vault for the jump host
data "azuread_client_config" "current" {}

module "avs_keyvault_with_access_policy" {
  source = "../../modules/avs_key_vault"

  #values to create the keyvault
  rg_name                   = azurerm_resource_group.avs_log_processing.name
  rg_location               = azurerm_resource_group.avs_log_processing.location
  keyvault_name             = var.keyvault_name
  azure_ad_tenant_id        = data.azuread_client_config.current.tenant_id
  deployment_user_object_id = data.azuread_client_config.current.object_id
  tags                      = var.tags
}

#create the logstash vms and use cloud-init to install and configure logstash
module "avs_logstash_vms" {
  source   = "../../modules/avs_log_filtering_vm"
  for_each = { for vm in var.logstash_vms : vm.vm_name => vm }

  rg_name            = azurerm_resource_group.avs_log_processing.name
  rg_location        = azurerm_resource_group.avs_log_processing.location
  tags               = var.tags
  vm_name            = each.value.vm_name
  vm_sku             = each.value.vm_sku
  logstash_subnet_id = var.logstash_subnet_id
  key_vault_id       = module.avs_keyvault_with_access_policy.keyvault_id

  logstash_values = {
    eventHubConnectionString                    = module.create_event_hub_resources.event_hub_connection_string
    eventHubConsumerGroupName                   = module.create_event_hub_resources.event_hub_consumer_group_name
    eventHubInputStorageAccountConnectionString = module.create_event_hub_resources.event_hub_storage_account_name
    lawPluginAppId                              = module.create_logging_service_principal.logging_application_id
    lawPluginAppSecret                          = module.create_logging_service_principal.logging_application_secret
    lawPluginTenantId                           = data.azuread_client_config.current.tenant_id
    lawPluginDataCollectionEndpointURI          = module.create_log_analytics_resources.logs_ingestion_endpoint
    lawPluginDcrImmutableId                     = module.create_log_analytics_resources.dcr_immutable_id
    lawPluginDcrStreamName                      = module.create_log_analytics_resources.dcr_stream_name
  }

  depends_on = [
    module.avs_keyvault_with_access_policy
  ]
}


#######################################################################################################################
# Configure a diagnostic setting on the private cloud to send the syslog data to the event hub
#######################################################################################################################

resource "azurerm_monitor_diagnostic_setting" "private_cloud_syslog" {
  name                           = var.diagnostics_setting_name
  target_resource_id             = var.private_cloud_resource_id
  eventhub_name                  = module.create_event_hub_resources.event_hub_name
  eventhub_authorization_rule_id = module.create_event_hub_resources.event_hub_authorization_rule_id

  enabled_log {
    category = "VMwareSyslog"

    retention_policy {
      enabled = false
    }
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
  module_identifier                       = lower("avs_test_deploy_logstash_syslog_filter")
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
