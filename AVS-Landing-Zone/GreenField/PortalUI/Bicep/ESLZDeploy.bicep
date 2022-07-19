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
@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string = ''
@description('The SKU that should be used for the first cluster, ensure you have quota for the given SKU before deploying')
@allowed([
  'AV36'
  'AV36T'
  'AV36P'
])
param PrivateCloudSKU string = 'AV36'
@description('The number of nodes to be deployed in the first/default cluster, ensure you have quota before deploying')
param PrivateCloudHostCount int = 3
@description('Existing Private Cloud Name')
param ExistingPrivateCloudName string = ''
@description('Existing Private Cloud Id')
param ExistingPrivateCloudResourceId string = ''

//Azure Networking
@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('A string value to skip the networking deployment')
param DeployNetworking bool = false
@description('Set this to true if you are redeploying, and the VNet already exists')
param GatewayExists bool = false
@description('Does the GatewaySubnet Exist')
param GatewaySubnetExists bool = false
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param NewVNetAddressSpace string = ''
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param NewVnetNewGatewaySubnetAddressPrefix string = ''
@description('The Existing VNet name')
param ExistingVnetName string = ''
@description('The Existing Gateway name')
param ExistingGatewayName string = ''
@description('The existing vnet gatewaysubnet id')
param ExistingGatewaySubnetId string = ''
@description('The existing vnet new gatewaysubnet prefix')
param ExistingVnetNewGatewaySubnetPrefix string = ''

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
param JumpboxSku string = 'Standard_D2s_v3'
@description('The subnet CIDR used for the Bastion Subnet. Must be a /26 or greater within the VNetAddressSpace')
param BastionSubnet string = ''

//On-premise Networking
@description('A boolean flag to deploy a Route Serrver or skip')
param DeployRouteServer bool = false
@description('A boolean flag to deploy a Route Serrver or skip')
param RouteServerVNetName string = ''
@description('Does a RouteServerSubnet exists?')
param RouteServerSubnetExists bool = false
@description('Flag to check onpremise connectivity method, ExpressRoute or VPN')
param OnPremConnectivity string = ''
@description('The subnet CIDR used for the RouteServer Subnet')
param RouteServerSubnetPrefix string = ''

//Monitoring
@description('Deploy AVS Dashboard')
param DeployDashboard bool = false
@description('Deploy Azure Monitor metric alerts for your AVS Private Cloud')
param DeployMetricAlerts bool = false
@description('Deploy Service Health Alerts for AVS')
param DeployServiceHealth bool = false
@description('Email addresses to be added to the alerting action group. Use the format ["name1@domain.com","name2@domain.com"].')
param AlertEmails string = ''

//Addons
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

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Prefix: Prefix
    Location: Location
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    PrivateCloudHostCount: PrivateCloudHostCount
    PrivateCloudSKU: PrivateCloudSKU
    TelemetryOptOut: TelemetryOptOut
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
    ExistingVnetName : ExistingVnetName
    GatewayExists : GatewayExists
    ExistingGatewayName : ExistingGatewayName
    GatewaySubnetExists : GatewaySubnetExists
    ExistingGatewaySubnetId : ExistingGatewaySubnetId
    ExistingVnetNewGatewaySubnetPrefix : ExistingVnetNewGatewaySubnetPrefix
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

module RouteServer 'Modules/RouteServer.bicep' = if ((OnPremConnectivity == 'VPN') && (DeployRouteServer)) {
  name: '${deploymentPrefix}-RouteServer'
  params: {
    Prefix: Prefix
    Location: Location
    VNetName: DeployNetworking ? AzureNetworking.outputs.VNetName : RouteServerVNetName
    RouteServerSubnetPrefix : RouteServerSubnetPrefix
    RouteServerSubnetExists : RouteServerSubnetExists
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
  }
}

module OperationalMonitoring 'Modules/Monitoring.bicep' = if ((DeployMetricAlerts) || (DeployServiceHealth) || (DeployDashboard)) {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: Location
    DeployMetricAlerts : DeployMetricAlerts
    DeployServiceHealth : DeployServiceHealth
    DeployDashboard : DeployDashboard
    PrimaryPrivateCloudName : DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrimaryPrivateCloudResourceId : DeployPrivateCloud ? AVSCore.outputs.PrivateCloudResourceId : ExistingPrivateCloudResourceId
    ExRConnectionResourceId : DeployNetworking ? VNetConnection.outputs.ExRConnectionResourceId : ''
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
