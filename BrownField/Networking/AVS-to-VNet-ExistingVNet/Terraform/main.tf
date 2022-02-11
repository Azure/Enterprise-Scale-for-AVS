data "azurerm_vmware_private_cloud" "existing" {
  name                = var.PrivateCloudName
  resource_group_name = var.PrivateCloudResourceGroup
}

#check this is the proper way to name the authorization
resource "azurerm_vmware_express_route_authorization" "thisVnet" {
  name             = var.GatewayName
  private_cloud_id = data.azurerm_vmware_private_cloud.existing.id
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  name                       = var.PrivateCloudName
  location                   = var.Location
  resource_group_name        = var.DeploymentResourceGroupName
  type                       = "ExpressRoute"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.ERGateway.id
  express_route_circuit_id   = data.azurerm_vmware_private_cloud.existing.circuit[0].express_route_id
  authorization_key          = azurerm_vmware_express_route_authorization.thisVnet.express_route_authorization_key
  routing_weight             = 0
}