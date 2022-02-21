resource "azurerm_virtual_network_gateway_connection" "avs" {
  name                = "${var.prefix}-AVS"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway.id
  express_route_circuit_id   = azurerm_vmware_private_cloud.privatecloud.circuit[0].express_route_id
  authorization_key = azurerm_vmware_express_route_authorization.expressrouteauthkey.express_route_authorization_key
}
