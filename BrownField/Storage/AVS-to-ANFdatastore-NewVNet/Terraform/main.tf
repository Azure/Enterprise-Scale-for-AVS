provider "azurerm" {
  alias      = "AVS-to-VNet-NewVnet"
  partner_id = "938cd838-e22a-47da-8a6f-bdda923e3edb"
  features {}
}

resource "azurerm_resource_group" "deploymentRG" {
  provider = azurerm.AVS-to-VNet-NewVnet
  name     = var.DeploymentResourceGroupName
  location = var.Location
}

resource "azurerm_virtual_network" "vnetGatewayVnet" {
  provider            = azurerm.AVS-to-VNet-NewVnet
  name                = var.VNetName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name
  address_space       = var.VNetAddressSpaceCIDR
}

resource "azurerm_subnet" "gatewaySubnet" {
  provider             = azurerm.AVS-to-VNet-NewVnet
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.deploymentRG.name
  virtual_network_name = azurerm_virtual_network.vnetGatewayVnet.name
  address_prefixes     = var.VNetGatewaySubnetCIDR
}

resource "azurerm_subnet" "ANFDelegatedSubnet" {
  provider             = azurerm.AVS-to-VNet-NewVnet
  name                 = "ANFDelegatedSubnet"
  resource_group_name  = azurerm_resource_group.deploymentRG.name
  virtual_network_name = azurerm_virtual_network.vnetGatewayVnet.name
  address_prefixes     = var.VNetANFDelegatedSubnetCIDR
}

resource "azurerm_public_ip" "gatewayIP" {
  provider            = azurerm.AVS-to-VNet-NewVnet
  name                = "${var.GatewayName}-PIP"
  resource_group_name = azurerm_resource_group.deploymentRG.name
  location            = azurerm_resource_group.deploymentRG.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_virtual_network_gateway" "ERGateway" {
  provider            = azurerm.AVS-to-VNet-NewVnet
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

#assumes the same subscription (need to reference different provider blocks if a separate sub is required.
data "azurerm_vmware_private_cloud" "existing" {
  provider            = azurerm.AVS-to-VNet-NewVnet
  name                = var.PrivateCloudName
  resource_group_name = var.PrivateCloudResourceGroup
}

#check this is the proper way to name the authorization
resource "azurerm_vmware_express_route_authorization" "thisVnet" {
  provider         = azurerm.AVS-to-VNet-NewVnet
  name             = azurerm_virtual_network.vnetGatewayVnet.name
  private_cloud_id = data.azurerm_vmware_private_cloud.existing.id
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  provider            = azurerm.AVS-to-VNet-NewVnet
  name                = var.PrivateCloudName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.ERGateway.id
  express_route_circuit_id   = data.azurerm_vmware_private_cloud.existing.circuit[0].express_route_id

  authorization_key = azurerm_vmware_express_route_authorization.thisVnet.express_route_authorization_key
  routing_weight    = 0
}