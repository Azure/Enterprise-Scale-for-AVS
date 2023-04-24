targetScope = 'subscription'

param Location string
param Prefix string
param VNetName string
param RouteServerSubnetPrefix string
param RouteServerSubnetExists bool

resource NetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Network'
  location: Location
}

module RouteServer 'RouteServer/RouteServer.bicep' = {
  scope: NetworkResourceGroup
  name: '${deployment().name}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetName: VNetName
    RouteServerSubnetPrefix : RouteServerSubnetPrefix
    RouteServerSubnetExists : RouteServerSubnetExists
  }
}

output RouteServer string = RouteServer.outputs.RouteServer
output RouteServerSubnetId string = RouteServer.outputs.NewRouteServerSubnetId
output ExistingRouteServerSubnetId string = RouteServer.outputs.ExistingRouteServerSubnetId
output NetworkResourceGroup string = NetworkResourceGroup.name
