# This module creates the virtual network and required subnets

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-VNet"
  address_space       = [var.vnetaddressspace]
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.gatewaysubnet]
}

resource "azurerm_subnet" "azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.azurebastionsubnet]
}

resource "azurerm_subnet" "jumpboxsubnet" {
  name                 = "JumpboxSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.jumpboxsubnet]
}
