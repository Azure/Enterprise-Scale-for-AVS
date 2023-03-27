targetScope = 'subscription'

@description('Name of the existing primary private cloud that will contain the global reach resource')
param PrimaryPrivateCloudName string

@description('Resource gorup name of the existing primary private cloud')
param PrimaryPrivateCloudResourceGroup string

@description('Name of the existing secondary private cloud that global reach will connect to')
param SecondaryPrivateCloudName string

@description('Resource gorup name of the existing secondary private cloud')
param SecondaryPrivateCloudResourceGroup string

// Generate an auth key via a module for the secondary private cloud
module SecondaryAuthKey 'Modules/AVSAuthorization.bicep' = {
  name: 'SecondaryAuthKey'
  scope: resourceGroup(SecondaryPrivateCloudResourceGroup)
  params: {
    AuthKeyName: 'GR-${PrimaryPrivateCloudName}'
    PrivateCloudName: SecondaryPrivateCloudName
  }
}

// Setup global reach on the primary private cloud
module GlobalReach 'Modules/GlobalReach.bicep' = {
  name: 'GlobalReach'
  scope: resourceGroup(PrimaryPrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrimaryPrivateCloudName
    ExpressRouteId: SecondaryAuthKey.outputs.ExpressRouteId
    ExpressRouteAuthorizationKey: SecondaryAuthKey.outputs.ExpressRouteAuthorizationKey
  }
}
