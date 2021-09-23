targetScope = 'subscription'

param PrivateCloudName string
param PrivateCloudResourceGroup string

module HCX 'AVSAddins/HCX.bicep' = {
  name: 'AVS-Addins-HCX'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
  }
}
