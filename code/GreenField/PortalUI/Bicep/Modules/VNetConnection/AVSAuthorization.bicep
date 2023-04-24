param PrivateCloudName string
param ConnectionName string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2021-06-01' = {
  name: ConnectionName
  parent: PrivateCloud
}

output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = PrivateCloud.properties.circuit.expressRouteID
