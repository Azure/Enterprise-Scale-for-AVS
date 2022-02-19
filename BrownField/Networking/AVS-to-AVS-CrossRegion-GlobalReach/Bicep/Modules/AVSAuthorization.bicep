@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The authorization key name to be created')
param AuthKeyName string

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

// Generate a new ExR Auth Key within the existing private cloud
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2021-06-01' = {
  name: AuthKeyName
  parent: PrivateCloud
}

// Return the Express Route ID and the new Authorization Key
output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = PrivateCloud.properties.circuit.expressRouteID

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
