param PrivateCloudName string
param PrivateCloudResourceGroup string = resourceGroup().name
param PrivateCloudSubscriptionId string = subscription().id

param GatewayName string
param ConnectionName string
param Location string = resourceGroup().location

module AVSAuthorization 'Module-AVSAuthorization.bicep' = {
  name: 'AVSAuthorization'
  params: {
    ConnectionName: ConnectionName
    PrivateCloudName: PrivateCloudName
  }
  scope: resourceGroup(PrivateCloudSubscriptionId, PrivateCloudResourceGroup)
}

resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = {
  name: GatewayName
}

resource Connection 'Microsoft.Network/connections@2021-02-01' = {
  name: ConnectionName
  location: Location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    virtualNetworkGateway1: {
      id: Gateway.id
      properties: {}
    }
    peer: {
      id: AVSAuthorization.outputs.ExpressRouteId
    }
    authorizationKey: AVSAuthorization.outputs.ExpressRouteAuthorizationKey
  }
}
