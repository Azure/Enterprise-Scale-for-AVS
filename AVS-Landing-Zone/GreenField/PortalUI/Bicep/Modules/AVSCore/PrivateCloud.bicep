param Prefix string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string
param TelemetryOptOut bool

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' = {
  name: '${Prefix}-SDDC'
  sku: {
    name: SKUName
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    internet: 'Disabled'
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-1cf4a3e3-529c-4fb2-ba6a-63dff7d71586'
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
