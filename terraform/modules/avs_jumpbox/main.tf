resource "random_password" "userpass" {
  length           = 20
  special          = true
  override_special = "_-!."
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "${var.jumpbox_name}-password"
  value        = random_password.userpass.result
  key_vault_id = var.key_vault_id
  depends_on   = [var.key_vault_id]
}

resource "azurerm_network_interface" "nic" {
  name                = var.jumpbox_nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.jumpbox_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.jumpbox_sku
  admin_username      = var.admin_username
  admin_password      = random_password.userpass.result
  tags                = var.tags
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
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
  module_identifier                       = lower("avs_jumpbox")
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