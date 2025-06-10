@description('Name of the virtual network')
param vnetName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Address space for the virtual network')
param vnetAddressPrefix string = 'x.y.z.0/24'

@description('Tags for the resources')
param tags object = {}

@description('DNS servers to use for the virtual network, empty array means use Azure-provided DNS')
param dnsServers array = []

// Create the virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: !empty(dnsServers) ? {
      dnsServers: dnsServers
    } : null
    subnets: []  // Subnets will be added separately
  }
}

@description('The resource ID of the virtual network')
output vnetId string = vnet.id

@description('The name of the virtual network')
output vnetName string = vnet.name
