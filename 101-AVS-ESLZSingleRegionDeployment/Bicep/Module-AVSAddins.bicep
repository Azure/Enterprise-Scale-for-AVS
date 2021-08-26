targetScope = 'subscription'

param PrivateCloudName string
param PrivateCloudResourceGroup string

module HCX 'Module-AVSAddins-HCX.bicep' = {
  name: 'AVS-Addins-HCX'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
  }
}
