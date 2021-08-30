targetScope = 'subscription'

param VNetPrefix string
param AVSPrefix string = VNetPrefix
param PrivateCloudResourceGroup string
param PrivateCloudName string
param NetworkResourceGroup string
param GatewayName string

module AVSExRAuthorization 'Module-AVSAuthorization.bicep' = {
  scope: resourceGroup(PrivateCloudResourceGroup)
  name: 'ESLZDeploy-AVS-AVSExRVNetConnection-AVSExRAuthorization'
  params: {
    ConnectionName: '${VNetPrefix}-VNet'
    PrivateCloudName: PrivateCloudName
  }
}

module VNetExRConnection 'Module-VNetExRConnection.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: 'ESLZDeploy-AVS-AVSExRVNetConnection-VNetExRConnection'
  params: {
    ConnectionName: '${AVSPrefix}-AVS'
    GatewayName: GatewayName
    ExpressRouteAuthorizationKey: AVSExRAuthorization.outputs.ExpressRouteAuthorizationKey
    ExpressRouteId: AVSExRAuthorization.outputs.ExpressRouteId
  }
}

output ExRConnectionResourceId string = VNetExRConnection.outputs.ExRConnectionResourceId
