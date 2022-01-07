resource "azurerm_public_ip" "bastionpip" {
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.jumpbox.location
  resource_group_name = azurerm_resource_group.jumpbox.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.jumpbox.location
  resource_group_name = azurerm_resource_group.jumpbox.name

 ip_configuration {
    name                 = "IpConf"
    subnet_id            = azurerm_subnet.azurebastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}