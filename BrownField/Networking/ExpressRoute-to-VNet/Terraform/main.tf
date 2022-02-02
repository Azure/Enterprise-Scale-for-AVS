data "azurerm_express_route_circuit" "ERCircuit" {
  name                = var.expressRouteName
  resource_group_name = var.resourceGroupNameExpressRoute
}

data "azurerm_virtual_network_gateway" "ERGateway" {
  name                = var.gatewayName
  resource_group_name = var.resourceGroupNameVnetGateway
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  name                = var.connectionName
  location            = data.azurerm_virtual_network_gateway.ERGateway.location
  resource_group_name = var.resourceGroupNameVnetGateway

  type                       = "ExpressRoute"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.ERGateway.id
  express_route_circuit_id   = data.azurerm_express_route_circuit.ERCircuit.id

  authorization_key = var.expressRouteAuthorizationKey
  routing_weight    = 0
}