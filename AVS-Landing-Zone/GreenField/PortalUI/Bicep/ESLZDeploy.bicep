targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'AVS'
@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

//Private Cloud
@description('Set this to false if the Private Cloud already exists')
param DeployPrivateCloud bool = false
@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param PrivateCloudName string = '${Prefix}-sddc'
@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param PrivateCloudResourceGroupName string = '${Prefix}-PrivateCloud'
@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string = ''
@description('The SKU that should be used for the first cluster, ensure you have quota for the given SKU before deploying')
@allowed([
  'AV36'
  'AV36T'
  'AV36P'
  'AV36PT'
  'AV52'
])
param PrivateCloudSKU string = 'AV36'
@description('The number of nodes to be deployed in the first/default cluster, ensure you have quota before deploying')
param PrivateCloudHostCount int = 3
@description('Existing Private Cloud Name')
param ExistingPrivateCloudName string = ''
@description('Existing Private Cloud Id')
param ExistingPrivateCloudResourceId string = ''

//Azure Networking
@description('A string value to skip the networking deployment')
param DeployNetworking bool = false
@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param NewNetworkResourceGroupName string = '${Prefix}-Network'
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param NewNetworkName string = '${Prefix}-vnet'
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param NewVNetAddressSpace string = ''
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param NewVnetNewGatewaySubnetAddressPrefix string = ''
@description('The Existing Gateway name')
param ExistingNetworkResourceId string = ''
@description('The Existing Gateway name')
param ExistingGatewayName string = ''

//Jumpbox
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
param JumpboxSku string = 'Standard_B2ms'
@description('Set the OS version to use')
@allowed([
  'win2022'
  'win2019'
  'win11'
  'win11ms'
  'ubuntu2004gen2'
])
param operatingSystemSKU string = 'win2019'


//Jumpbox Bootstrap OS
param BootstrapJumpboxVM bool = false
@description('The path for Jumpbox VM bootstrap PowerShell script file (expecting "bootstrap.ps1" file)')
param BootstrapPath string = 'https://raw.githubusercontent.com/shaunjacob/AVSLevelUpFY23/master/LevelUp/LZwtihAVS/Bicep/Bootstrap.ps1'
@description('The command to trigger running the bootstrap script. If was not provided, then the expected script file name must be "bootstrap.ps1")')
param BootstrapCommand string = 'powershell.exe -ExecutionPolicy Unrestricted -File bootstrap.ps1'
@description('The subnet CIDR used for the Bastion Subnet. Must be a /26 or greater within the VNetAddressSpace')
param BastionSubnet string = ''

// Monitoring Module Parameters
param MonitoringResourceGroupName string = '${Prefix}-Operational'
param DeployMonitoring bool = false
param DeployDashboard bool = false
param DeployMetricAlerts bool = false
param DeployServiceHealth bool = false
param AlertEmails string = ''
param CPUUsageThreshold int = 60
param MemoryUsageThreshold int = 60
param StorageUsageThreshold int = 60

//Diagnostic Module Parameters
param LoggingResourceGroupName string = '${Prefix}-Operational'
param DeployDiagnostics bool = false
param EnableAVSLogsWorkspaceSetting bool = false
param DeployActivityLogDiagnostics bool = false
param EnableAVSLogsStorageSetting bool = false
param DeployWorkbook bool = false
param DeployWorkspace bool = false
param NewWorkspaceName string = '${Prefix}-log'
param NewStorageAccountName string = ''
param DeployStorageAccount bool = false
param ExistingWorkspaceId string = ''
param ExistingStorageAccountId string = ''
param StorageRetentionDays int = 1

//Addons
@description('Should HCX be deployed as part of the deployment')
param DeployHCX bool = false
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

param utc string = utcNow()

//Variables
var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'
var varCuaid = '1cf4a3e3-529c-4fb2-ba6a-63dff7d71586'

//Custom Naming
@description('Optional. AVS resources custom naming. (Default: false)')
param avsUseCustomNaming bool = true
var PrefixLowercase = toLower(Prefix)
var uniquestorageaccountname  = '${PrefixLowercase}${uniqueString(utc)}'
var customPrivateCloudResourceGroupName = avsUseCustomNaming ? PrivateCloudResourceGroupName : '${Prefix}-PrivateCloud'
var customSDDCName = avsUseCustomNaming ? PrivateCloudName : '${Prefix}-sddc'
var customNetworkResourceGroupName = avsUseCustomNaming ? NewNetworkResourceGroupName : '${Prefix}-Network'
var customNetworkName = avsUseCustomNaming ? NewNetworkName : '${Prefix}-vnet'
var customMonitoringResourceGroupName = avsUseCustomNaming ? MonitoringResourceGroupName : '${Prefix}-Operational'
var customLoggingResourceGroupName = avsUseCustomNaming ? LoggingResourceGroupName : '${Prefix}-Operational'
var customWorkspaceName = avsUseCustomNaming ? NewWorkspaceName : '${Prefix}-log'
var customStorageAccountName = avsUseCustomNaming ? NewStorageAccountName : uniquestorageaccountname



module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Prefix: Prefix
    Location: Location
    PrivateCloudName: customSDDCName
    PrivateCloudResourceGroupName: customPrivateCloudResourceGroupName
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    PrivateCloudHostCount: PrivateCloudHostCount
    PrivateCloudSKU: PrivateCloudSKU
    DeployPrivateCloud : DeployPrivateCloud
    ExistingPrivateCloudResourceId : ExistingPrivateCloudResourceId
  }
}

module AzureNetworking 'Modules/AzureNetworking.bicep' = if (DeployNetworking) {
  name: '${deploymentPrefix}-AzureNetworking'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    NewNetworkName: customNetworkName
    NewNetworkResourceGroupName: customNetworkResourceGroupName
    ExistingNetworkResourceId : ExistingNetworkResourceId
    ExistingGatewayName : ExistingGatewayName
    NewVNetAddressSpace: NewVNetAddressSpace
    NewVnetNewGatewaySubnetAddressPrefix: NewVnetNewGatewaySubnetAddressPrefix
  }
}

module VNetConnection 'Modules/VNetConnection.bicep' = if (DeployNetworking) {
  name: '${deploymentPrefix}-VNetConnection'
  params: {
    GatewayName: DeployNetworking ? AzureNetworking.outputs.GatewayName : 'none'
    NetworkResourceGroup: DeployNetworking ? AzureNetworking.outputs.NetworkResourceGroup : 'none'
    VNetPrefix: Prefix
    PrivateCloudName: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName 
    Location: Location
  }
}

module Jumpbox 'Modules/JumpBox.bicep' = if (DeployJumpbox) {
  name: '${deploymentPrefix}-Jumpbox'
  params: {
    Prefix: Prefix
    Location: Location
    Username: JumpboxUsername
    Password: JumpboxPassword
    VNetName: DeployNetworking ? AzureNetworking.outputs.VNetName : ''
    VNetResourceGroup: DeployNetworking ? AzureNetworking.outputs.NetworkResourceGroup : ''
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
    JumpboxSku: JumpboxSku
    operatingSystemSKU: operatingSystemSKU
    BootstrapJumpboxVM: BootstrapJumpboxVM
    BootstrapPath: BootstrapPath
    BootstrapCommand: BootstrapCommand
  }
}

module OperationalMonitoring 'Modules/Monitoring.bicep' = if ((DeployMonitoring)) {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    Location: Location
    MonitoringResourceGroupName : customMonitoringResourceGroupName
    DeployMetricAlerts : DeployMetricAlerts
    DeployServiceHealth : DeployServiceHealth
    DeployDashboard : DeployDashboard
    DeployWorkbook : DeployWorkbook
    PrivateCloudName : DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrivateCloudResourceId : DeployPrivateCloud ? AVSCore.outputs.PrivateCloudResourceId : ExistingPrivateCloudResourceId
    CPUUsageThreshold: CPUUsageThreshold
    MemoryUsageThreshold: MemoryUsageThreshold
    StorageUsageThreshold: StorageUsageThreshold
  }
}

module Diagnostics 'Modules/Diagnostics.bicep' = if ((DeployDiagnostics)) {
  name: '${deploymentPrefix}-Diagnostics'
  params: {
    Location: Location
    LoggingResourceGroupName: customLoggingResourceGroupName
    EnableAVSLogsWorkspaceSetting: EnableAVSLogsWorkspaceSetting
    DeployActivityLogDiagnostics: DeployActivityLogDiagnostics
    EnableAVSLogsStorageSetting: EnableAVSLogsStorageSetting
    DeployWorkspace: DeployWorkspace
    NewWorkspaceName: customWorkspaceName
    DeployStorageAccount: DeployStorageAccount
    NewStorageAccountName: customStorageAccountName
    PrivateCloudName: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrivateCloudResourceId: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudResourceId : ExistingPrivateCloudResourceId
    ExistingWorkspaceId: ExistingWorkspaceId
    ExistingStorageAccountId: ExistingStorageAccountId
    StorageRetentionDays: StorageRetentionDays
  }
}

module Addons 'Modules/AVSAddons.bicep' = if ((DeployHCX) || (DeploySRM)) {
  name: '${deploymentPrefix}-AVSAddons'
  params: {
    PrivateCloudName: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
    DeployHCX: DeployHCX
    DeploySRM: DeploySRM
    SRMLicenseKey: SRMLicenseKey
    VRServerCount: VRServerCount
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdSubscription.bicep' = if (!TelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(deployment().name, Location)}'
  params: {}
}
