param PrivateCloudName string
@secure()
param ExpressRouteAuthorizationKey string
@secure()
param ExpressRouteId string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

resource GlobalReach 'Microsoft.AVS/privateClouds/globalReachConnections@2021-06-01' = {
  name: guid(ExpressRouteId, ExpressRouteAuthorizationKey)
  parent: PrivateCloud
  properties: {
    authorizationKey: ExpressRouteAuthorizationKey
    peerExpressRouteCircuit: ExpressRouteId
  }
}
