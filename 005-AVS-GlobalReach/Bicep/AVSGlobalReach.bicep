param PrivateCloudName string
param GlobalReachName string = newGuid()
@secure()
param ExpressRouteAuthorizationKey string
@secure()
param ExpressRouteId string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

resource GlobalReach 'Microsoft.AVS/privateClouds/globalReachConnections@2021-06-01' = {
  name: GlobalReachName
  parent: PrivateCloud
  properties: {
    authorizationKey: ExpressRouteAuthorizationKey
    peerExpressRouteCircuit: ExpressRouteId
  }
}
