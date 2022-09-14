param PrivateCloudName string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string
param TelemetryOptOut bool

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: PrivateCloudName
  sku: {
    name: SKUName
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-8a85fe17-c0c9-439c-9d98-1ae024815163'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
