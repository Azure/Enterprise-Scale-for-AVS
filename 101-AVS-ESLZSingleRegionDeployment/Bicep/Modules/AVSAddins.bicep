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
  name: 'AVS-Addins-HCX'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
  }
}

module SRM 'AVSAddins/SRM.bicep' = if (DeploySRM) {
  name: 'AVS-Addins-SRM'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
    SRMLicenseKey: SRMLicenseKey
    VRServerCount: VRServerCount
  }
}
