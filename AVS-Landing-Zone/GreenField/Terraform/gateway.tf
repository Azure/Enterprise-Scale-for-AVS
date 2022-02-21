resource "azurerm_public_ip" "gatewaypip" {
  name                = "${var.prefix}-GW-pip"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "${var.prefix}-GW"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  type     = "ExpressRoute"
  sku      = "Standard"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.gatewaypip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }
}