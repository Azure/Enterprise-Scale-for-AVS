@description('Name of the network security group')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

// Network security group with RDP allowed only from within the VNet
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDPFromVNet'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

// Outputs
output nsgId string = nsg.id
output nsgName string = nsg.name
