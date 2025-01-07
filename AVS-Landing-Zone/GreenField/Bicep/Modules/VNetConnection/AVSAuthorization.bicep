param PrivateCloudName string
param ConnectionName string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: PrivateCloudName
}
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2023-09-01' = {
  name: ConnectionName
  parent: PrivateCloud
  properties: {
    expressRouteId: PrivateCloud.properties.circuit.expressRouteID
  }
}

output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = PrivateCloud.properties.circuit.expressRouteID
