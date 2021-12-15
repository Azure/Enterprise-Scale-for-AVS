@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The authorization key name to be created')
param AuthKeyName string

@description('Opt-out of deployment telemetry')
param TelemetryOptOut bool

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

// Generate a new ExR Auth Key within the existing private cloud
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2021-06-01' = {
  name: AuthKeyName
  parent: PrivateCloud
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-754599a0-0a6f-424a-b4c5-1b12be198ae8-${uniqueString(resourceGroup().id, PrivateCloudName)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// Return the Express Route ID and the new Authorization Key
output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = PrivateCloud.properties.circuit.expressRouteID
