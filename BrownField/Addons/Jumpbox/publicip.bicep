@description('Name of the public IP')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

// Create a public IP 
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Outputs
output publicIpId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
