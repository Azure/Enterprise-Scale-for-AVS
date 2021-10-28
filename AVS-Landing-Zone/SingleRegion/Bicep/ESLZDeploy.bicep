targetScope = 'subscription'

@description('The region the AVS Private Cloud & associated resources will be deployed to')
param Location string
@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'AVS'

@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string

@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param VNetAddressSpace string
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param VNetGatewaySubnet string

@description('Email addresses to be added to the alerting action group')
param AlertEmails array = []
@description('Should a Jumpbox & Bastion be deployed to access the Private Cloud')

param DeployJumpbox bool = false
@description('Username for the Jumpbox VM')
param JumpboxUsername string = 'avsjump'
@secure()
@description('Password for the Jumpbox VM, can be changed later')
param JumpboxPassword string = ''
@description('The subnet CIDR used for the Jumpbox VM Subnet. Must be a /26 or greater within the VNetAddressSpace')
param JumpboxSubnet string = ''
@description('The sku to use for the Jumpbox VM, must have quota for this within the target region')
param JumpboxSku string = 'Standard_D2s_v3'
@description('The subnet CIDR used for the Bastion Subnet. Must be a /26 or greater within the VNetAddressSpace')
param BastionSubnet string = ''

@description('Should HCX be deployed as part of the deployment')
param DeployHCX bool = true
@description('Should SRM be deployed as part of the deployment')
param DeploySRM bool = false
@description('License key to be used if SRM is deployed')
param SRMLicenseKey string = ''
@minValue(1)
@maxValue(10)
@description('Number of vSphere Replication Servers to be created if SRM is deployed')
param VRServerCount int = 1

@description('Opt-out of deployment telemetry')
param TelemetryOptOut bool = false

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, deployment().location)}'

module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Prefix: Prefix
    Location: Location
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    TelemetryOptOut: TelemetryOptOut
  }
}

module Networking 'Modules/Networking.bicep' = {
  name: '${deploymentPrefix}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    VNetAddressSpace: VNetAddressSpace
    VNetGatewaySubnet: VNetGatewaySubnet
  }
}

module VNetConnection 'Modules/VNetConnection.bicep' = {
  name: '${deploymentPrefix}-VNet'
  params: {
    GatewayName: Networking.outputs.GatewayName
    NetworkResourceGroup: Networking.outputs.NetworkResourceGroup
    VNetPrefix: Prefix
    PrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
  }
}

module Addons 'Modules/AVSAddons.bicep' = {
  name: '${deploymentPrefix}-AVSAddons'
  params: {
    PrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
    DeployHCX: DeployHCX
    DeploySRM: DeploySRM
    SRMLicenseKey: SRMLicenseKey
    VRServerCount: VRServerCount
  }
}

module Jumpbox 'Modules/JumpBox.bicep' = if (DeployJumpbox) {
  name: '${deploymentPrefix}-Jumpbox'
  params: {
    Prefix: Prefix
    Location: Location
    Username: JumpboxUsername
    Password: JumpboxPassword
    VNetName: Networking.outputs.VNetName
    VNetResourceGroup: Networking.outputs.NetworkResourceGroup
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
    JumpboxSku: JumpboxSku
  }
}

module OperationalMonitoring 'Modules/Monitoring.bicep' = {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: Location
    PrimaryPrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrimaryPrivateCloudResourceId: AVSCore.outputs.PrivateCloudResourceId
    JumpboxResourceId: DeployJumpbox ? Jumpbox.outputs.JumpboxResourceId : ''
    VNetResourceId: Networking.outputs.VNetResourceId
    ExRConnectionResourceId: VNetConnection.outputs.ExRConnectionResourceId
  }
}
