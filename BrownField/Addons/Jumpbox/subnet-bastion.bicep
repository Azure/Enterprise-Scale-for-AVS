@description('Name of the virtual network')
param vnetName string

// Name for Azure Bastion subnet must be exactly 'AzureBastionSubnet' per Azure requirements
var subnetName = 'AzureBastionSubnet'

@description('Address prefix for the Azure Bastion subnet')
param subnetPrefix string = 'x.y.z.32/27'

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
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

@description('The resource ID of the Bastion subnet')
output subnetId string = subnet.id

@description('The name of the Bastion subnet')
output subnetName string = subnet.name
