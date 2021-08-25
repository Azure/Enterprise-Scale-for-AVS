param PrivateCloudName string
param NetworkBlock string
param ManagementClusterSize int = 3
param Location string = resourceGroup().location
param InternetEnabled bool = false

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: PrivateCloudName
  sku: {
    name: 'AV36'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    internet: InternetEnabled ? 'Enabled' : 'Disabled'
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}
