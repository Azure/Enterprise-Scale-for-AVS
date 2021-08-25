targetScope = 'subscription'

param PrimaryLocation string
param Prefix string = 'AVS'
param PrivateCloudAddressSpace string
param VNetAddressSpace string
param VNetGatewaySubnet string
param InternetViaVWan bool = false
param AlertEmails array = []

var PrimaryPrefix = '${Prefix}-Primary'

module PrimaryRegion 'Module-RegionDeploy.bicep' = {
  name: 'PrimaryRegion'
  params: {
    Prefix: PrimaryPrefix
    Location: PrimaryLocation
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    VNetAddressSpace: VNetAddressSpace
    VNetGatewaySubnet: VNetGatewaySubnet
    PrivateCloudInternetEnabled: !InternetViaVWan
  }
}

module OperationalMonitoring 'Module-Operational-Monitoring.bicep' = {
  name: 'OperationalMonitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: PrimaryLocation
    PrimaryPrivateCloudName: PrimaryRegion.outputs.PrivateCloudName
    PrimaryPrivateCloudResourceId: PrimaryRegion.outputs.PrivateCloudResourceId
  }
}
