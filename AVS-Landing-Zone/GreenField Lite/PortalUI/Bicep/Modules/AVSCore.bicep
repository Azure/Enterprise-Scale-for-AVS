targetScope = 'subscription'

param Location string
param PrivateCloudName string
param PrivateCloudResourceGroupName string
param PrivateCloudAddressSpace string
param PrivateCloudSKU string
param PrivateCloudHostCount int
param DeployPrivateCloud bool
param ExistingPrivateCloudResourceId string

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (DeployPrivateCloud) {
  name: PrivateCloudResourceGroupName
  location: Location
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = if (DeployPrivateCloud) {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-PrivateCloud'
  params: {
    Location: Location
    PrivateCloudName : PrivateCloudName
    NetworkBlock: PrivateCloudAddressSpace
    SKUName: PrivateCloudSKU
    ManagementClusterSize: PrivateCloudHostCount
  }
}

output PrivateCloudName string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudName : ''
output PrivateCloudResourceGroupName string = DeployPrivateCloud ? PrivateCloudResourceGroup.name : split(ExistingPrivateCloudResourceId,'/')[4]
output PrivateCloudResourceId string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudResourceId : ''
