@description('Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group')
param PrimaryPrivateCloudName string

@description('Full resource id of the secondary private cloud, must be in the same region as the primary')
param SecondaryPrivateCloudId string

@description('Opt-out of deployment telemetry')
param TelemetryOptOut bool = false

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrimaryPrivateCloudName
}

// Create the link between the 2 private clouds
resource PrivateCloudLink 'Microsoft.AVS/privateClouds/cloudLinks@2021-06-01' = {
  name: guid(SecondaryPrivateCloudId)
  parent: PrivateCloud
  properties: {
    linkedCloud: SecondaryPrivateCloudId
  }
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-754599a0-0a6f-424a-b4c5-1b12be198ae8-${uniqueString(resourceGroup().id, PrimaryPrivateCloudName)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

