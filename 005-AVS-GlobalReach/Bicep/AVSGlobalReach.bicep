@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The Express Route Authorization Key to be redeemed by the connection')
@secure()
param ExpressRouteAuthorizationKey string

@description('The id of the Express Route to create the connection to')
@secure()
param ExpressRouteId string

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

// Create the global reach link
resource GlobalReach 'Microsoft.AVS/privateClouds/globalReachConnections@2021-06-01' = {
  name: guid(ExpressRouteId, ExpressRouteAuthorizationKey)
  parent: PrivateCloud
  properties: {
    authorizationKey: ExpressRouteAuthorizationKey
    peerExpressRouteCircuit: ExpressRouteId
  }
}
