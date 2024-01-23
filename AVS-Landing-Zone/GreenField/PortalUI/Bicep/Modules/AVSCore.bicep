targetScope = 'subscription'

param Prefix string
param Location string
param PrivateCloudAddressSpace string
param PrivateCloudName string
param PrivateCloudResourceGroupName string = 'avs-rg'
param PrivateCloudSKU string
param PrivateCloudHostCount int
param DeployPrivateCloud bool
param ExistingPrivateCloudResourceId string
param tags object

//var DeployNew = empty(ExistingPrivateCloudId)

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (DeployPrivateCloud) {
  name: PrivateCloudResourceGroupName
  location: Location
  tags: tags
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = if (DeployPrivateCloud) {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-PrivateCloud'
  params: {
    Prefix: Prefix
    Location: Location
    PrivateCloudName: PrivateCloudName
    NetworkBlock: PrivateCloudAddressSpace
    SKUName: PrivateCloudSKU
    ManagementClusterSize: PrivateCloudHostCount
    tags: tags
  }
}


output PrivateCloudName string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudName : ''
output PrivateCloudResourceGroupName string = DeployPrivateCloud ? PrivateCloudResourceGroup.name : split(ExistingPrivateCloudResourceId,'/')[4]
output PrivateCloudResourceId string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudResourceId : ''
