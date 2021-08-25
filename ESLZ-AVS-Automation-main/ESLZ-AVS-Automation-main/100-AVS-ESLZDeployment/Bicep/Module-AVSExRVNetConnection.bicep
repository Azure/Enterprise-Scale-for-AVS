targetScope = 'subscription'

param VNetPrefix string
param AVSPrefix string = VNetPrefix
param PrivateCloudResourceGroup string
param PrivateCloudName string
param NetworkResourceGroup string
param GatewayName string

module AVSExRAuthorization 'Module-AVSAuthorization.bicep' = {
  scope: resourceGroup(PrivateCloudResourceGroup)
  name: 'AVSExRAuthorization'
  params: {
    ConnectionName: '${VNetPrefix}-VNet'
    PrivateCloudName: PrivateCloudName
  }
}

module VNetExRConnection 'Module-VNetExRConnection.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: 'VNetExRConnection'
  params: {
    ConnectionName: '${AVSPrefix}-AVS'
    GatewayName: GatewayName
    ExpressRouteAuthorizationKey: AVSExRAuthorization.outputs.ExpressRouteAuthorizationKey
    ExpressRouteId: AVSExRAuthorization.outputs.ExpressRouteId
  }
}
