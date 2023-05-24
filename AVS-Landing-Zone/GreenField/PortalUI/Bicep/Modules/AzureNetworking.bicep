targetScope = 'subscription'

param Location string = 'southeastasia'
param Prefix string = 'SJTEST1'
param VNetExists bool = true
param NewNetworkResourceGroupName string = 'SJTESTNET1'
param NewNetworkName string = 'SJTESTNET1-vnet'
param NewVNetAddressSpace string = '10.111.0.0/16'
param NewVnetNewGatewaySubnetAddressPrefix string = '10.111.0.0/24'
param ExistingNetworkResourceId string = '/subscriptions/1caa5ab4-523f-4851-952b-1b689c48fae9/resourceGroups/AVS-SEA-Network/providers/Microsoft.Network/virtualNetworks/AVS-SEA-vnet'
param ExistingGatewayName string = 'AVS-SEA-gw'

var ExistingNetworkResourceGroupName = split(ExistingNetworkResourceId,'/')[4]

resource NewNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (!VNetExists) {
  name: NewNetworkResourceGroupName
  location: Location
}

module NewNetwork 'AzureNetworking/NewVNetWithGW.bicep' = if (!VNetExists) {
  scope: NewNetworkResourceGroup
  name: '${deployment().name}-NewNetwork'
  params: {
    Prefix: Prefix
    Location: Location
    NewNetworkName: NewNetworkName
    NewVNetAddressSpace: NewVNetAddressSpace
    NewVnetNewGatewaySubnetAddressPrefix: NewVnetNewGatewaySubnetAddressPrefix
  }
}


output GatewayName string = (!VNetExists) ? NewNetwork.outputs.GatewayName : ExistingGatewayName
output VNetName string = (!VNetExists) ? NewNetwork.outputs.VNetName : 'none'
output VNetResourceId string = (!VNetExists) ? NewNetwork.outputs.VNetResourceId : 'none'
output NetworkResourceGroup string = (!VNetExists) ? NewNetworkResourceGroup.name : ExistingNetworkResourceGroupName
output NetworkResourceGroupLocation string = (!VNetExists) ? NewNetworkResourceGroup.location : 'none'

