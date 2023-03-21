data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

resource "azurerm_key_vault" "infra_vault" {
  name                            = var.keyvault_name
  location                        = var.rg_location
  resource_group_name             = var.rg_name
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  sku_name                        = "standard"
  tags                            = var.tags
}

#set a wait timer to handle creation lag issues
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_key_vault.infra_vault]

  create_duration = "30s"
}

#Add this block back when configuring a service principal to run the configuration
/*  
resource "azurerm_key_vault_access_policy" "service_principal_access" {
  key_vault_id = azurerm_key_vault.infra_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.service_principal_object_id

  certificate_permissions = [
    "Get", "Create","Delete","DeleteIssuers","GetIssuers","Import","List","ListIssuers","ManageContacts","ManageIssuers","Recover","Restore","SetIssuers","Update"
  ]

  secret_permissions = [
    "Get","List","Set","Delete","Backup","Recover","Restore"
  ]

  storage_permissions = [
      "Backup","Delete","DeleteSAS","Get","GetSAS","List","ListSAS","Recover","RegenerateKey","Restore","Set","SetSAS","Update"
  ]
}
*/

#Deploy an access policy for the deployment user to allow for secret injection during larger deployments
resource "azurerm_key_vault_access_policy" "deployment_user_access" {
  key_vault_id = azurerm_key_vault.infra_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_client_config.current.object_id

  certificate_permissions = [
    "Get", "Create", "Delete", "DeleteIssuers", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Recover", "Restore", "SetIssuers", "Update"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Recover", "Restore"
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]

  depends_on = [
    time_sleep.wait_30_seconds
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
  module_identifier                       = lower("avs_key_vault")
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