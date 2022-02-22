@description('The existing virtual network gateway name')
param GatewayName string

@description('The connection name to be created')
param ConnectionName string

@description('The location of the virtual network gateway')
param Location string = resourceGroup().location


@description('The Express Route Authorization Key to be redeemed by the connection')
@secure()
param ExpressRouteAuthorizationKey string

@description('The id of the Express Route to create the connection to')
@secure()
param ExpressRouteId string

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

// Get a reference to the existing virtual network gateway
resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = {
  name: GatewayName
}

// Create a new connection for the Express Route details that were provided
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

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
