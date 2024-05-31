
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-jumpbox"
  location            = azurerm_resource_group.jumpbox.location
  resource_group_name = azurerm_resource_group.jumpbox.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.jumpboxsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.prefix}-jumpbox"
  resource_group_name = azurerm_resource_group.jumpbox.name
  location            = azurerm_resource_group.jumpbox.location
  size                = var.jumpboxsku
  admin_username      = var.adminusername
  admin_password      = random_password.admin_password.result
  zone                = 1
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }
}

resource "random_password" "admin_password" {
  length           = 23
  special          = true
  numeric          = true
  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
}

resource "random_string" "namestring" {
  length   = 4
  special  = false
  upper    = false
  lower    = true
}

resource "azurerm_key_vault_secret" "admin_password" {
  key_vault_id    = module.avm_res_keyvault_vault.resource.id
  name            = "${var.prefix}-jumpbox-${var.adminusername}-password"
  value           = random_password.admin_password.result
}

module "avm_res_keyvault_vault" {
  source                 = "Azure/avm-res-keyvault-vault/azurerm"
  version                = "0.5.3"
  tenant_id              = data.azurerm_client_config.current.tenant_id
  name                   = "${var.key_vault_name}-${random_string.namestring.result}"
  resource_group_name    = azurerm_resource_group.jumpbox.name
  location               = azurerm_resource_group.jumpbox.location
  enabled_for_deployment = true
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}