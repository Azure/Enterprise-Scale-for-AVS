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