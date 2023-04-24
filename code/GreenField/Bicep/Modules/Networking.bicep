targetScope = 'subscription'

param Location string
param Prefix string
param VNetExists bool
param VNetAddressSpace string
param VNetGatewaySubnet string

resource NetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Network'
  location: Location
}

module Network 'Networking/VNetWithGW.bicep' = {
  scope: NetworkResourceGroup
  name: '${deployment().name}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    VNetAddressSpace: VNetAddressSpace
    VNetGatewaySubnet: VNetGatewaySubnet
  }
}

output GatewayName string = Network.outputs.GatewayName
output VNetName string = Network.outputs.VNetName
output VNetResourceId string = Network.outputs.VNetResourceId
output NetworkResourceGroup string = NetworkResourceGroup.name
