targetScope = 'subscription'

param PrimaryLocation string
param SecondaryLocation string
param Prefix string = 'AVS'
param NetworkLayout object = {
  PrimaryRegion: {
    PrivateCloudAddressSpace: '10.110.0.0/22'
    VNetAddressSpace: '10.111.0.0/16'
    VNetGatewaySubnet: '10.111.0.0/24'
  }
  SecondaryRegion: {
    PrivateCloudAddressSpace: '10.120.0.0/22'
    VNetAddressSpace: '10.121.0.0/16'
    VNetGatewaySubnet: '10.121.0.0/24'
  }
}
param InternetViaVWan bool = false
param AlertEmails array = [
  'scholden@microsoft.com'
]

var PrimaryPrefix = '${Prefix}-Primary'
var SecondaryPrefix = '${Prefix}-Secondary'

module PrimaryRegion 'Module-RegionDeploy.bicep' = {
  name: 'PrimaryRegion'
  params: {
    Prefix: PrimaryPrefix
    Location: PrimaryLocation
    PrivateCloudAddressSpace: NetworkLayout.PrimaryRegion.PrivateCloudAddressSpace
    VNetAddressSpace: NetworkLayout.PrimaryRegion.VNetAddressSpace
    VNetGatewaySubnet: NetworkLayout.PrimaryRegion.VNetGatewaySubnet
    PrivateCloudInternetEnabled: !InternetViaVWan
  }
}

module SecondaryRegion 'Module-RegionDeploy.bicep' = {
  name: 'SecondaryRegion'
  params: {
    Prefix: SecondaryPrefix
    Location: SecondaryLocation
    PrivateCloudAddressSpace: NetworkLayout.SecondaryRegion.PrivateCloudAddressSpace
    VNetAddressSpace: NetworkLayout.SecondaryRegion.VNetAddressSpace
    VNetGatewaySubnet: NetworkLayout.SecondaryRegion.VNetGatewaySubnet
    PrivateCloudInternetEnabled: !InternetViaVWan
  }
}

module CrossConnectivity 'Module-CrossConnectivity.bicep' = {
  name: 'CrossConnectivity'
  params: {
    PrimaryPrefix: PrimaryPrefix
    PrimaryPrivateCloudName: PrimaryRegion.outputs.PrivateCloudName
    PrimaryPrivateCloudResourceGroup: PrimaryRegion.outputs.PrivateCloudResourceGroupName
    PrimaryVNetName: PrimaryRegion.outputs.VNetName
    PrimaryGatewayName: PrimaryRegion.outputs.GatewayName
    PrimaryNetworkResourceGroup: PrimaryRegion.outputs.NetworkResourceGroup
    SecondaryPrefix: SecondaryPrefix
    SecondaryPrivateCloudName: SecondaryRegion.outputs.PrivateCloudName
    SecondaryPrivateCloudResourceGroup: SecondaryRegion.outputs.PrivateCloudResourceGroupName
    SecondaryVNetName: SecondaryRegion.outputs.VNetName
    SecondaryGatewayName: SecondaryRegion.outputs.GatewayName
    SecondaryNetworkResourceGroup: SecondaryRegion.outputs.NetworkResourceGroup
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
    SecondaryPrivateCloudName: SecondaryRegion.outputs.PrivateCloudName
    SecondaryPrivateCloudResourceId: SecondaryRegion.outputs.PrivateCloudResourceId
  }
}
