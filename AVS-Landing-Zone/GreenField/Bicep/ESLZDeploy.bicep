targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'AVS'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string
@description('The SKU that should be used for the first cluster, ensure you have quota for the given SKU before deploying')
@allowed([
  'AV36'
  'AV36T'
  'AV36P'
  'AV36PT'
  'AV52'
])
param PrivateCloudSKU string = 'AV36P'
@description('Optional: Connectivity to Internet through Managed SNAT Service')
@allowed([
  'Disabled'
  'Enabled'
])
param Internet string = 'Disabled'
@description('The number of nodes to be deployed in the first/default cluster, ensure you have quota before deploying')
param PrivateCloudHostCount int = 3
@description('Optional: Assign Jumpbox VM as Contributor on AVS Private Cloud')
param AssignJumpboxAsAVSContributor bool = false

@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param VNetAddressSpace string
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param VNetGatewaySubnet string

@description('Email addresses to be added to the alerting action group. Use the format ["name1@domain.com","name2@domain.com"].')
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
@description('The OS Version for the Jumpbox VM. By default, it is Microsoft Windows Server 2012 Azure Edition with small disk for storage to reduce costs.')
@allowed([
  '2016-Datacenter'
  '2016-Datacenter-smalldisk'
  '2019-Datacenter'
  '2019-Datacenter-smalldisk'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-smalldisk'
])
param OSVersion string  = '2022-datacenter-azure-edition-smalldisk'
@description('Optional: Enable high performance attributes for VM, such as setting Storage to Premium and enabling Accelerated Networking')
param HighPerformance bool = true
@description('Should run a bootstrap PowerShell script on the Jumpbox VM or not')
param BootstrapJumpboxVM bool = false
@description('The path for Jumpbox VM bootstrap PowerShell script file (expecting "bootstrap.ps1" file)')
param BootstrapPath string = 'https://raw.githubusercontent.com/Azure/Enterprise-Scale-for-AVS/main/AVS-Landing-Zone/GreenField/Scripts/bootstrap.ps1'
@description('The command to trigger running the bootstrap script. If was not provided, then the expected script file name must be "bootstrap.ps1")')
param BootstrapCommand string = 'powershell.exe -ExecutionPolicy Unrestricted -File bootstrap.ps1'
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

//Variables
var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'


module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Prefix: Prefix
    Location: Location
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    PrivateCloudHostCount: PrivateCloudHostCount
    PrivateCloudSKU: PrivateCloudSKU
    Internet: Internet
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
    Location: Location
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
    OSVersion: OSVersion
    HighPerformance: HighPerformance
    BootstrapJumpboxVM: BootstrapJumpboxVM
    BootstrapPath: BootstrapPath
    BootstrapCommand: BootstrapCommand
  }
}

module JumpboxAVSContributor 'Modules/AVSRBAC.bicep' = if(AssignJumpboxAsAVSContributor) {
  name: '${deploymentPrefix}-Contributor-Assignment'
  params: {
    PrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
    JumpboxSAMIPrincipalId: Jumpbox.outputs.JumpboxSAMIPrincipalId
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

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdSubscription.bicep' = if (!TelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(deployment().name, Location)}'
  params: {}
}
