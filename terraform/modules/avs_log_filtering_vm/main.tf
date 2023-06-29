
######################################################################################################################
# Build and configure the logstash vm
######################################################################################################################
resource "random_password" "keystore_password" {
  length  = 20
  special = false
  upper   = true
  lower   = true
}

#generate the cloud init config file
data "template_file" "configure_logstash" {
  template = file("${path.module}/templates/configure_logstash.yaml")

  vars = {
    eventHubConnectionString                    = var.logstash_values.eventHubConnectionString
    eventHubConsumerGroupName                   = var.logstash_values.eventHubConsumerGroupName
    eventHubInputStorageAccountConnectionString = var.logstash_values.eventHubInputStorageAccountConnectionString
    logstashKeyStorePassword                    = random_password.keystore_password.result
    lawPluginAppId                              = var.logstash_values.lawPluginAppId
    lawPluginAppSecret                          = var.logstash_values.lawPluginAppSecret
    lawPluginTenantId                           = var.logstash_values.lawPluginTenantId
    lawPluginDataCollectionEndpointURI          = var.logstash_values.lawPluginDataCollectionEndpointURI
    lawPluginDcrImmutableId                     = var.logstash_values.lawPluginDcrImmutableId
    lawPluginDcrStreamName                      = var.logstash_values.lawPluginDcrStreamName
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.configure_logstash.rendered
  }
}

resource "random_password" "admin_password" {
  length  = 20
  special = false
  upper   = true
  lower   = true
}

resource "azurerm_network_interface" "logstash_nic" {
  name                = "${var.vm_name}-nic-1"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.logstash_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "logstash_vm" {
  name                            = var.vm_name
  resource_group_name             = var.rg_name
  location                        = var.rg_location
  size                            = var.vm_sku #"Standard_E2as_v5"
  admin_username                  = "azureuser"
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false
  custom_data                     = data.template_cloudinit_config.config.rendered

  network_interface_ids = [
    azurerm_network_interface.logstash_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

#write secret to keyvault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.vm_name}-azureuser-password"
  value        = random_password.admin_password.result
  key_vault_id = var.key_vault_id
}

#write logstash keystore secret to keyvault
resource "azurerm_key_vault_secret" "keystore_password" {
  name         = "${var.vm_name}-keystore-password"
  value        = random_password.keystore_password.result
  key_vault_id = var.key_vault_id
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
  module_identifier                       = lower("avs_log_filtering_vm")
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