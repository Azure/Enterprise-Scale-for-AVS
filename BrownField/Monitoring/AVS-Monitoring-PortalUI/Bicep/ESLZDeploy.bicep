targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = ''

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

// Monitoring Module Parameters
param DeployMonitoring bool = false
param DeployDashboard bool = false
param DeployMetricAlerts bool = false
param DeployServiceHealth bool = false
param AlertEmails string = ''
param PrivateCloudName string = ''
param PrivateCloudResourceId string = ''
param CPUUsageThreshold int
param MemoryUsageThreshold int
param StorageUsageThreshold int

//Diagnostic Module Parameters
param DeployDiagnostics bool = false
param DeployAVSLogsWorkspace bool = false
param DeployActivityLogDiagnostics bool = false
param DeployAVSLogsStorage bool = false
param DeployWorkbook bool = false
param DeployWorkspace bool = false
param DeployStorageAccount bool = false
param ExistingWorkspaceId string = ''
param ExistingStorageAccountId string = ''
param DiagnosticsPrivateCloudName string = ''
param DiagnosticsPrivateCloudResourceId string = ''
param StorageRetentionDays int = 1

//Variables
var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

// Customer Usage Attribution Id
var varCuaid = '4e6c118a-ccde-4471-a873-b91dc6d7b00e'

module OperationalMonitoring 'Modules/Monitoring.bicep' = if ((DeployMonitoring)) {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    Location: Location
    DeployMetricAlerts : DeployMetricAlerts
    DeployServiceHealth : DeployServiceHealth
    DeployDashboard : DeployDashboard
    DeployWorkbook : DeployWorkbook
    PrivateCloudName : PrivateCloudName
    PrivateCloudResourceId : PrivateCloudResourceId
    CPUUsageThreshold: CPUUsageThreshold
    MemoryUsageThreshold: MemoryUsageThreshold
    StorageUsageThreshold: StorageUsageThreshold
  }
}

module Diagnostics 'Modules/Diagnostics.bicep' = if ((DeployDiagnostics)) {
  name: '${deploymentPrefix}-Diagnostics'
  params: {
    Location: Location
    Prefix: Prefix
    DeployAVSLogsWorkspace: DeployAVSLogsWorkspace
    DeployActivityLogDiagnostics: DeployActivityLogDiagnostics
    DeployAVSLogsStorage: DeployAVSLogsStorage
    DeployWorkspace: DeployWorkspace
    DeployStorageAccount: DeployStorageAccount
    PrivateCloudName: DiagnosticsPrivateCloudName
    PrivateCloudResourceId: DiagnosticsPrivateCloudResourceId
    ExistingWorkspaceId: ExistingWorkspaceId
    ExistingStorageAccountId: ExistingStorageAccountId
    StorageRetentionDays: StorageRetentionDays
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdSubscription.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(deployment().name, Location)}'
  params: {}
}
