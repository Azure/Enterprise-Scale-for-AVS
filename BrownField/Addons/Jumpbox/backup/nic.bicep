@description('Name of the network interface')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Subnet resource ID')
param subnetId string

@description('Network security group resource ID')
param nsgId string

@description('Tags for the resource')
param tags object = {}

// Network interface without public IP
resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

// Outputs
output nicId string = nic.id
output nicName string = nic.name
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
