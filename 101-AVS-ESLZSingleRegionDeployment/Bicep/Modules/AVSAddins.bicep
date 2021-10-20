targetScope = 'subscription'

param PrivateCloudName string
param PrivateCloudResourceGroup string

param DeployHCX bool

param DeploySRM bool
param SRMLicenseKey string
@minValue(1)
@maxValue(10)
param VRServerCount int

module HCX 'AVSAddins/HCX.bicep' = if (DeployHCX) {
  name: '${deployment().name}-HCX'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
  }
}

module SRM 'AVSAddins/SRM.bicep' = if (DeploySRM) {
  name: '${deployment().name}-SRM'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
    SRMLicenseKey: SRMLicenseKey
    VRServerCount: VRServerCount
  }
}
