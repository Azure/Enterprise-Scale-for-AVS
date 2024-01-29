targetScope = 'subscription'

param VNetPrefix string
param AVSPrefix string = VNetPrefix
param PrivateCloudResourceGroup string
param PrivateCloudName string
param NetworkResourceGroup string
param GatewayName string
param Location string
param tags object

module AVSExRAuthorization 'VNetConnection/AVSAuthorization.bicep' = {
  scope: resourceGroup(PrivateCloudResourceGroup)
  name: '${deployment().name}-ExRAuth'
  params: {
    ConnectionName: '${VNetPrefix}-VNet'
    PrivateCloudName: PrivateCloudName
  }
}

module VNetExRConnection 'VNetConnection/VNetExRConnection.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: '${deployment().name}-ExR'
  params: {
    ConnectionName: '${AVSPrefix}-AVS'
    GatewayName: GatewayName
    ExpressRouteAuthorizationKey: AVSExRAuthorization.outputs.ExpressRouteAuthorizationKey
    ExpressRouteId: AVSExRAuthorization.outputs.ExpressRouteId
    Location: Location
    tags: tags
  }
}

output ExRConnectionResourceId string = VNetExRConnection.outputs.ExRConnectionResourceId
