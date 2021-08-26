targetScope = 'subscription'

@description('The region the AVS Private Cloud & associated resources will be deployed to')
param PrimaryLocation string
@description('The prefix to use on resources inside this template')
param Prefix string = 'AVS'
@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string
@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param VNetAddressSpace string
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param VNetGatewaySubnet string
@description('***TODO: Add***')
param InternetViaVWan bool = false
@description('***TODO: Add***')
param AlertEmails array = []
@description('***TODO: Add***')
param DeployJumpbox bool = false
@description('***TODO: Add***')
param JumpboxUsername string = 'avsjump'
@secure()
@description('***TODO: Add***')
param JumpboxPassword string = ''
@description('***TODO: Add***')
param JumpboxSubnet string = ''
@description('***TODO: Add***')
param BastionSubnet string = ''

module PrimaryRegion 'Module-RegionDeploy.bicep' = {
  name: 'PrimaryRegion'
  params: {
    Prefix: Prefix
    Location: PrimaryLocation
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    VNetExists: VNetExists
    VNetAddressSpace: VNetAddressSpace
    VNetGatewaySubnet: VNetGatewaySubnet
    PrivateCloudInternetEnabled: !InternetViaVWan
  }
}

module Addins 'Module-AVSAddins.bicep' = {
  name: 'AVS-Addins'
  params: {
    PrivateCloudName: PrimaryRegion.outputs.PrivateCloudName
    PrivateCloudResourceGroup: PrimaryRegion.outputs.PrivateCloudResourceGroupName
  }
}

module Jumpbox 'Module-JumpBox.bicep' = if (DeployJumpbox) {
  name: 'Jumpbox'
  params: {
    Prefix: Prefix
    Location: PrimaryLocation
    Username: JumpboxUsername
    Password: JumpboxPassword
    VNetName: PrimaryRegion.outputs.VNetName
    VNetResourceGroup: PrimaryRegion.outputs.NetworkResourceGroup
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
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
    JumpboxResourceId: DeployJumpbox ? Jumpbox.outputs.JumpboxResourceId : ''
    VNetResourceId: PrimaryRegion.outputs.VNetResourceId
    ExRConnectionResourceId: PrimaryRegion.outputs.ExRConnectionResourceId
  }
}
