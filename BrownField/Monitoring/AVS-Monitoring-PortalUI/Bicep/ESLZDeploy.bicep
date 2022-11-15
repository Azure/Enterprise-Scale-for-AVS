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
param StorageCriticalThreshold int

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
param StorageRetentionDays int

//Variables
var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

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
    StorageCriticalThreshold: StorageCriticalThreshold
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

