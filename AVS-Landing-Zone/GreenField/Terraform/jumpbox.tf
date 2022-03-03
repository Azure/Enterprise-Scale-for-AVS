
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
  admin_password      = var.adminpassword
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
}