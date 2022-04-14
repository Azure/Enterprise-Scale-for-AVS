targetScope = 'subscription'

param Location string
param Prefix string
param PrivateCloudAddressSpace string
param PrivateCloudSKU string
param PrivateCloudHostCount int
param TelemetryOptOut bool

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-PrivateCloud'
  location: Location
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = {
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

output PrivateCloudName string = PrivateCloud.outputs.PrivateCloudName
output PrivateCloudResourceGroupName string = PrivateCloudResourceGroup.name
output PrivateCloudResourceId string = PrivateCloud.outputs.PrivateCloudResourceId
