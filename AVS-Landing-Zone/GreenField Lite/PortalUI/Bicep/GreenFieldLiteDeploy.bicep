targetScope = 'subscription'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

//Private Cloud
@description('Set this to false if the Private Cloud already exists')
param DeployPrivateCloud bool = false
@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param PrivateCloudName string = ''
@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param PrivateCloudResourceGroupName string = ''
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
param PrivateCloudSKU string = 'AV36P'
@description('The number of nodes to be deployed in the first/default cluster, ensure you have quota before deploying')
param PrivateCloudHostCount int = 3
@description('Existing Private Cloud Name')
param ExistingPrivateCloudName string = ''
@description('Existing Private Cloud Id')
param ExistingPrivateCloudResourceId string = ''

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

//Variables
var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'
var varCuaid = '8a85fe17-c0c9-439c-9d98-1ae024815163'

module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Location: Location
    DeployPrivateCloud : DeployPrivateCloud
    PrivateCloudName : PrivateCloudName
    PrivateCloudResourceGroupName : PrivateCloudResourceGroupName
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    PrivateCloudHostCount: PrivateCloudHostCount
    PrivateCloudSKU: PrivateCloudSKU
    ExistingPrivateCloudResourceId : ExistingPrivateCloudResourceId
  }
}

module Addons 'Modules/AVSAddons.bicep' = {
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

module OperationalMonitoring 'Modules/Monitoring.bicep' = {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Location: Location
    DeployMetricAlerts : DeployMetricAlerts
    DeployServiceHealth : DeployServiceHealth
    DeployDashboard : DeployDashboard
    PrivateCloudResourceGroup : AVSCore.outputs.PrivateCloudResourceGroupName
    PrivateCloudName: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudName : ExistingPrivateCloudName
    PrivateCloudResourceId: DeployPrivateCloud ? AVSCore.outputs.PrivateCloudResourceId : ExistingPrivateCloudResourceId
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdSubscription.bicep' = if (!TelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(deployment().name, Location)}'
  params: {}
}
