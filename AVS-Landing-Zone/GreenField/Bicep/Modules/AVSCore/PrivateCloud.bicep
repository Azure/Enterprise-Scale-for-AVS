param Prefix string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string
param Internet string
param AddResourceLock bool

resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' = {
  name: '${Prefix}-SDDC'
  sku: {
    name: SKUName
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    internet: Internet
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

resource AVSLock 'Microsoft.Authorization/locks@2020-05-01' = if (AddResourceLock) {
  name: '${Prefix}-SDDCLock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Lock to prevent accidental deletion of the AVS Private Cloud'
  }
  scope: PrivateCloud
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
