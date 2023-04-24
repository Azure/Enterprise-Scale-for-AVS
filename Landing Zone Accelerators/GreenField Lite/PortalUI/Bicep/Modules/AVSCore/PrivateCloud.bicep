param PrivateCloudName string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string

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

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
