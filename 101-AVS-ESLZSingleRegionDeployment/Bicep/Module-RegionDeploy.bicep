targetScope = 'subscription'

param Location string
param Prefix string
param PrivateCloudAddressSpace string
param VNetExists bool
param VNetAddressSpace string
param VNetGatewaySubnet string
param PrivateCloudInternetEnabled bool

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-PrivateCloud'
  location: Location
}

module PrivateCloud 'Module-PrivateCloud.bicep' = {
  scope: PrivateCloudResourceGroup
  name: 'PrivateCloud'
  params: {
    Prefix: Prefix
    Location: Location
    NetworkBlock: PrivateCloudAddressSpace
    InternetEnabled: PrivateCloudInternetEnabled
  }
}

resource NetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Network'
  location: Location
}

module Network 'Module-VNetWithGW.bicep' = {
  scope: NetworkResourceGroup
  name: 'Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    VNetAddressSpace: VNetAddressSpace
    VNetGatewaySubnet: VNetGatewaySubnet
  }
}

module AVSExRVNetConnection 'Module-AVSExRVNetConnection.bicep' = {
  name: 'AVSExRVNetConnection'
  params: {
    GatewayName: Network.outputs.GatewayName
    NetworkResourceGroup: NetworkResourceGroup.name
    VNetPrefix: Prefix
    PrivateCloudName: PrivateCloud.outputs.PrivateCloudName
    PrivateCloudResourceGroup: PrivateCloudResourceGroup.name
  }
}

output PrivateCloudName string = PrivateCloud.outputs.PrivateCloudName
output PrivateCloudResourceGroupName string = PrivateCloudResourceGroup.name
output PrivateCloudResourceId string = PrivateCloud.outputs.PrivateCloudResourceId

output GatewayName string = Network.outputs.GatewayName
output VNetName string = Network.outputs.VNetName
output NetworkResourceGroup string = NetworkResourceGroup.name

output ExRConnectionResourceId string = AVSExRVNetConnection.outputs.ExRConnectionResourceId
output VNetResourceId string = Network.outputs.VNetResourceId

