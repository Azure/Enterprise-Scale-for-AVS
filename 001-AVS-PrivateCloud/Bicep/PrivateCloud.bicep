@description('The name of the Private Cloud to be created')
param PrivateCloudName string

@description('The network block to be used for the management address space, should be a valid /22 CIDR block in the format: 10.0.0.0/22')
param NetworkBlock string

@description('Size of the management (first) cluster within the Private Cloud')
param ManagementClusterSize int = 3

@description('The location the Private Cloud should be deployed to. Must have quota in this region prior to deployment')
param Location string = resourceGroup().location

// AVS Private Cloud Resource
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: PrivateCloudName
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
