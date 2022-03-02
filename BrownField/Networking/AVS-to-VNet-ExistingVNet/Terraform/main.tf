provider "azurerm" {
  alias      = "AVS-to-VNet-ExistingVNet"
  partner_id = "9dd111b1-82f0-4104-bcf9-18b777f0c78f"
  features {}
}

data "azurerm_vmware_private_cloud" "existing" {
  provider            = azurerm.AVS-to-VNet-ExistingVNet
  name                = var.PrivateCloudName
  resource_group_name = var.PrivateCloudResourceGroup
}

data "azurerm_virtual_network_gateway" "existingGateway" {
  provider            = azurerm.AVS-to-VNet-ExistingVNet
  name                = var.GatewayName
  resource_group_name = var.DeploymentResourceGroupName
}

#check this is the proper way to name the authorization
resource "azurerm_vmware_express_route_authorization" "thisVnet" {
  provider         = azurerm.AVS-to-VNet-ExistingVNet
  name             = var.GatewayName
  private_cloud_id = data.azurerm_vmware_private_cloud.existing.id
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  provider                   = azurerm.AVS-to-VNet-ExistingVNet
  name                       = var.PrivateCloudName
  location                   = var.Location
  resource_group_name        = var.DeploymentResourceGroupName
  type                       = "ExpressRoute"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.existingGateway.id
  express_route_circuit_id   = data.azurerm_vmware_private_cloud.existing.circuit[0].express_route_id
  authorization_key          = azurerm_vmware_express_route_authorization.thisVnet.express_route_authorization_key
  routing_weight             = 0
}