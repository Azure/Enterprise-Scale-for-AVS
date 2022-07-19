param GatewayName string
param ConnectionName string
param Location string

@secure()
param ExpressRouteAuthorizationKey string
@secure()
param ExpressRouteId string

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
      id: ExpressRouteId
    }
    authorizationKey: ExpressRouteAuthorizationKey
  }
}

output ExRConnectionResourceId string = Connection.id
