resource "azurerm_resource_group" "deploymentRG" {
  name     = var.DeploymentResourceGroupName
  location = var.Location
}

resource "azurerm_virtual_network" "vnetGatewayVnet" {
  name                = var.VNetName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name
  address_space       = var.VNetAddressSpaceCIDR
}

resource "azurerm_subnet" "gatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.deploymentRG.name
  virtual_network_name = azurerm_virtual_network.vnetGatewayVnet.name
  address_prefixes     = var.VNetGatewaySubnetCIDR
}

resource "azurerm_public_ip" "gatewayIP" {
  name                = "${var.GatewayName}-PIP"
  resource_group_name = azurerm_resource_group.deploymentRG.name
  location            = azurerm_resource_group.deploymentRG.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_virtual_network_gateway" "ERGateway" {
  name                = var.GatewayName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name

  type = "ExpressRoute"
  sku  = var.GatewaySku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gatewayIP.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaySubnet.id
  }
}

#assumes the same subscription (doesn't appear to be an easy way to do a reference to a different sub)
data "azurerm_vmware_private_cloud" "existing" {
  name                = var.PrivateCloudName
  resource_group_name = var.PrivateCloudResourceGroup
}

#check this is the proper way to name the authorization
resource "azurerm_vmware_express_route_authorization" "thisVnet" {
  name             = azurerm_virtual_network.vnetGatewayVnet.name
  private_cloud_id = data.azurerm_vmware_private_cloud.existing.id
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  name                = var.PrivateCloudName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.ERGateway.id
  #check to confirm the proper way to index the ExR block
  express_route_circuit_id = data.azurerm_vmware_private_cloud.existing.circuit[0].id

  authorization_key = azurerm_vmware_express_route_authorization.thisVnet.express_route_authorization_key
  routing_weight    = 0
}