@description('Name of the virtual network')
param vnetName string

@description('Name for the VM subnet')
param subnetName string = 'VMSubnet'

@description('Address prefix for the VM subnet')
param subnetPrefix string = 'x.y.z.0/27'

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
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

@description('The resource ID of the VM subnet')
output subnetId string = subnet.id

@description('The name of the VM subnet')
output subnetName string = subnet.name
