param Prefix string
param NetworkBlock string
param ManagementClusterSize int = 3
param Location string = resourceGroup().location

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: '${Prefix}-SDDC'
  sku: {
    name: 'AV36'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
