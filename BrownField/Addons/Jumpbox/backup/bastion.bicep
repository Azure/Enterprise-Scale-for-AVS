@description('Name for the Azure Bastion resource')
param bastionName string = 'jumpbox-bastion'

@description('Location for the Bastion resource')
param location string = resourceGroup().location

@description('Virtual network name where the Bastion subnet exists')
param vnetName string = ''

@description('Tags for the Bastion resource')
param tags object = {}

@description('Subnet resource ID')
param subnetId string = ''

@description('Public IP resource ID')
param publicIpId string = ''

// Check if we're using direct resource IDs or creating resources inline
var useDirectIds = !empty(subnetId) && !empty(publicIpId)

// Reference the existing AzureBastionSubnet if not using direct IDs
resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = if (!useDirectIds) {
  name: '${vnetName}/AzureBastionSubnet'
}

// Create a public IP for the Bastion service if not using a direct ID
resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = if (!useDirectIds) {
  name: '${bastionName}-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Deploy the Bastion service
resource bastion 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: bastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: useDirectIds ? subnetId : bastionSubnet.id
          }
          publicIPAddress: {
            id: useDirectIds ? publicIpId : bastionPublicIP.id
          }
        }
      }
    ]
  }
}

// Outputs
output bastionId string = bastion.id
output bastionName string = bastion.name
output publicIpId string = useDirectIds ? publicIpId : bastionPublicIP.id
