@description('Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group')
param PrimaryPrivateCloudName string

@description('Full resource id of the secondary private cloud, must be in the same region as the primary')
param SecondaryPrivateCloudId string

// Customer Usage Attribution Id
var varCuaid = '08d3edb1-3d70-4c0f-ab9f-f491b4a8d737'

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

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
