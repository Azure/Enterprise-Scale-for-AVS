@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The authorization key name to be created')
param AuthKeyName string

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: PrivateCloudName
}

// Generate a new ExR Auth Key within the existing private cloud
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2023-09-01' = {
  name: AuthKeyName
  parent: PrivateCloud
  properties: {
    expressRouteId: PrivateCloud.properties.circuit.expressRouteID
  }
}

// Return the Express Route ID and the new Authorization Key
output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = PrivateCloud.properties.circuit.expressRouteID
