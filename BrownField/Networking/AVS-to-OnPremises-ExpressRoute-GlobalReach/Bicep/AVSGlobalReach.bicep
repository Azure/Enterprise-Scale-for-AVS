@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The Express Route Authorization Key to be redeemed by the connection')
@secure()
param ExpressRouteAuthorizationKey string

@description('The id of the Express Route to create the connection to')
@secure()
param ExpressRouteId string

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

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

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
