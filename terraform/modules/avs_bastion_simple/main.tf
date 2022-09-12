resource "azurerm_public_ip" "bastionpip" {
  name                = var.bastion_pip_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                 = "IpConf"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}