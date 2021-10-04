targetScope = 'subscription'

param VNetPrefix string
param AVSPrefix string = VNetPrefix
param PrivateCloudResourceGroup string
param PrivateCloudName string
param NetworkResourceGroup string
param GatewayName string

module AVSExRAuthorization 'VNetConnection/AVSAuthorization.bicep' = {
  scope: resourceGroup(PrivateCloudResourceGroup)
  name: '${deployment().name}-AVSExRAuthorization'
  params: {
    ConnectionName: '${VNetPrefix}-VNet'
    PrivateCloudName: PrivateCloudName
  }
}

module VNetExRConnection 'VNetConnection/VNetExRConnection.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: '${deployment().name}-VNetExRConnection'
  params: {
    ConnectionName: '${AVSPrefix}-AVS'
    GatewayName: GatewayName
    ExpressRouteAuthorizationKey: AVSExRAuthorization.outputs.ExpressRouteAuthorizationKey
    ExpressRouteId: AVSExRAuthorization.outputs.ExpressRouteId
  }
}

output ExRConnectionResourceId string = VNetExRConnection.outputs.ExRConnectionResourceId
