// ExpressRoute Connection Module
@description('Name for the ExpressRoute connection')
param connectionName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('ExpressRoute circuit ID to connect to')
param circuitId string

@description('Authorization key for the ExpressRoute circuit')
@secure()
param authorizationKey string

@description('Name of the ExpressRoute gateway to connect to')
param gatewayName string = ''

@description('ExpressRoute gateway ID')
param gatewayId string = ''

@description('Tags for the resources')
param tags object = {}

// Check if we're using a direct ID or a name reference
var useDirectId = !empty(gatewayId)

// Reference to the existing ExpressRoute Gateway if using name
resource expressRouteGateway 'Microsoft.Network/virtualNetworkGateways@2023-04-01' existing = if (!useDirectId) {
  name: gatewayName
}

// Create the ExpressRoute connection
resource erConnection 'Microsoft.Network/connections@2023-04-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    connectionType: 'ExpressRoute'
    virtualNetworkGateway1: {
      id: useDirectId ? gatewayId : expressRouteGateway.id
    }
    peer: {
      id: circuitId
    }
    authorizationKey: authorizationKey
    routingWeight: 0
  }
}

// Outputs
output connectionId string = erConnection.id
output connectionName string = erConnection.name
