@description('Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group')
param PrimaryPrivateCloudName string

@description('Full resource id of the secondary private cloud, must be in the same region as the primary')
param SecondaryPrivateCloudId string

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
