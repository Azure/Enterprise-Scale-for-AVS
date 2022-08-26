resource "azurerm_public_ip" "gatewaypip" {
  name                = var.expressroute_pip_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"
  sku                 = "Basic" #required for an ultraperformance gateway
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = var.expressroute_gateway_name
  resource_group_name = var.rg_name
  location            = var.rg_location

  type = "ExpressRoute"
  sku  = var.expressroute_gateway_sku

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.gatewaypip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

resource "azurerm_virtual_network_gateway_connection" "avs" {
  name                = var.express_route_connection_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  enable_bgp          = true

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway.id
  express_route_circuit_id   = var.express_route_id
  authorization_key          = var.express_route_authorization_key
}