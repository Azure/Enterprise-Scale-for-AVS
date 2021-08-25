targetScope = 'subscription'

param PrimaryPrivateCloudName string
param PrimaryPrivateCloudResourceGroup string

param SecondaryPrivateCloudName string
param SecondaryPrivateCloudResourceGroup string

module SecondaryAuthKey 'Module-AVSAuthorization.bicep' = {
  name: 'SecondaryAuthKey'
  scope: resourceGroup(SecondaryPrivateCloudResourceGroup)
  params: {
    ConnectionName: 'GR-${PrimaryPrivateCloudName}'
    PrivateCloudName: SecondaryPrivateCloudName
  }
}

module GlobalReach 'Module-GlobalReach.bicep' = {
  name: 'GlobalReach'
  scope: resourceGroup(PrimaryPrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrimaryPrivateCloudName
    ExpressRouteId: SecondaryAuthKey.outputs.ExpressRouteId
    ExpressRouteAuthorizationKey: SecondaryAuthKey.outputs.ExpressRouteAuthorizationKey
  }
}
