@description('Name of the virtual network')
param vnetName string

// Name for Gateway subnet must be exactly 'GatewaySubnet' per Azure requirements
var subnetName = 'GatewaySubnet'

@description('Address prefix for the ExpressRoute Gateway subnet')
param subnetPrefix string = 'x.y.z.64/27'

// Reference to existing VNet
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
}

// Add subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: existingVnet
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
  }
}

@description('The resource ID of the Gateway subnet')
output subnetId string = subnet.id

@description('The name of the Gateway subnet')
output subnetName string = subnet.name
