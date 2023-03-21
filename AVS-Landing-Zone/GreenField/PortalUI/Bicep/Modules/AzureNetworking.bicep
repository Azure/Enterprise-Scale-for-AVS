targetScope = 'subscription'

param Location string
param Prefix string
param VNetExists bool
param ExistingVnetName string
param GatewayExists bool
param ExistingGatewayName string
param NewVNetAddressSpace string
param NewVnetNewGatewaySubnetAddressPrefix string
param GatewaySubnetExists bool
param ExistingVnetNewGatewaySubnetPrefix string
param ExistingGatewaySubnetId string


resource NetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Network'
  location: Location
}

module NewNetwork 'AzureNetworking/NewVNetWithGW.bicep' = if (!VNetExists) {
  scope: NetworkResourceGroup
  name: '${deployment().name}-NewNetwork'
  params: {
    Prefix: Prefix
    Location: Location
    NewVNetAddressSpace: NewVNetAddressSpace
    NewVnetNewGatewaySubnetAddressPrefix: NewVnetNewGatewaySubnetAddressPrefix
  }
}

module ExistingNetwork 'AzureNetworking/ExistingVNetWithGW.bicep' = if (VNetExists) {
  scope: NetworkResourceGroup
  name: '${deployment().name}-ExistingNetwork'
  params: {
    Prefix: Prefix
    Location: Location
    ExistingVnetName : ExistingVnetName
    GatewayExists : GatewayExists
    ExistingGatewayName : ExistingGatewayName
    GatewaySubnetExists : GatewaySubnetExists
    ExistingGatewaySubnetId : ExistingGatewaySubnetId
    ExistingVnetNewGatewaySubnetPrefix : ExistingVnetNewGatewaySubnetPrefix
  }
}

output GatewayName string = (!VNetExists) ? NewNetwork.outputs.GatewayName : ExistingNetwork.outputs.GatewayName
output VNetName string = (!VNetExists) ? NewNetwork.outputs.VNetName : ExistingNetwork.outputs.VNetName
output VNetResourceId string = (!VNetExists) ? NewNetwork.outputs.VNetResourceId : ExistingNetwork.outputs.VNetResourceId
output NetworkResourceGroup string = NetworkResourceGroup.name
