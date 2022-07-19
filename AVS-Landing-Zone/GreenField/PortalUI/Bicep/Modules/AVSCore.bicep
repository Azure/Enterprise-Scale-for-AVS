targetScope = 'subscription'

param Location string
param Prefix string
param PrivateCloudAddressSpace string
param PrivateCloudSKU string
param PrivateCloudHostCount int
param TelemetryOptOut bool
param DeployPrivateCloud bool
param ExistingPrivateCloudResourceId string

//var DeployNew = empty(ExistingPrivateCloudId)

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (DeployPrivateCloud) {
  name: '${Prefix}-PrivateCloud'
  location: Location
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = if (DeployPrivateCloud) {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-PrivateCloud'
  params: {
    Prefix: Prefix
    Location: Location
    NetworkBlock: PrivateCloudAddressSpace
    SKUName: PrivateCloudSKU
    ManagementClusterSize: PrivateCloudHostCount
    TelemetryOptOut: TelemetryOptOut
  }
}


output PrivateCloudName string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudName : ''
output PrivateCloudResourceGroupName string = DeployPrivateCloud ? PrivateCloudResourceGroup.name : split(ExistingPrivateCloudResourceId,'/')[4]
output PrivateCloudResourceId string = DeployPrivateCloud ? PrivateCloud.outputs.PrivateCloudResourceId : ''
