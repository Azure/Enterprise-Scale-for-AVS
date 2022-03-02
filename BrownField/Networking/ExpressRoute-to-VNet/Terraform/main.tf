provider "azurerm" {
  alias      = "expressRoute-To-Vnet"
  partner_id = "174ca090-c796-4183-bc1f-ac6578e81d39"
  features {}
}



data "azurerm_express_route_circuit" "ERCircuit" {
  provider            = azurerm.expressRoute-To-Vnet
  name                = var.expressRouteName
  resource_group_name = var.resourceGroupNameExpressRoute
}

data "azurerm_virtual_network_gateway" "ERGateway" {
  provider            = azurerm.expressRoute-To-Vnet
  name                = var.gatewayName
  resource_group_name = var.resourceGroupNameVnetGateway
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  provider            = azurerm.expressRoute-To-Vnet
  name                = var.connectionName
  location            = data.azurerm_virtual_network_gateway.ERGateway.location
  resource_group_name = var.resourceGroupNameVnetGateway

  type                       = "ExpressRoute"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.ERGateway.id
  express_route_circuit_id   = data.azurerm_express_route_circuit.ERCircuit.id

  authorization_key = var.expressRouteAuthorizationKey
  routing_weight    = 0
}