targetScope = 'subscription'

param Prefix string
param Location string
param MonitoringResourceGroupName string
param AlertEmails string
param DeployMetricAlerts bool
param DeployServiceHealth bool
param DeployDashboard bool
param DeployWorkbook bool
param PrivateCloudName string
param PrivateCloudResourceId string
param CPUUsageThreshold int
param MemoryUsageThreshold int
param StorageUsageThreshold int


resource MonitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: MonitoringResourceGroupName
  location: Location
}

module ActionGroup 'Monitoring/ActionGroup.bicep' = if ((DeployMetricAlerts) || (DeployServiceHealth)) {
  scope: MonitoringResourceGroup
  name: '${deployment().name}-ActionGroup'
  params: {
    Prefix: Prefix
    ActionGroupEmails: AlertEmails
  }
}

module PrimaryMetricAlerts 'Monitoring/MetricAlerts.bicep' = if (DeployMetricAlerts) {
  scope: MonitoringResourceGroup
  name: '${deployment().name}-MetricAlerts'
  params: {
    ActionGroupResourceId: ((DeployMetricAlerts) || (DeployServiceHealth)) ? ActionGroup.outputs.ActionGroupResourceId : ''
    AlertPrefix: PrivateCloudName
    PrivateCloudResourceId: PrivateCloudResourceId
    CPUUsageThreshold: CPUUsageThreshold
    MemoryUsageThreshold: MemoryUsageThreshold
    StorageUsageThreshold: StorageUsageThreshold
  }
}

module ServiceHealth 'Monitoring/ServiceHealth.bicep' = if (DeployServiceHealth) {
  scope: MonitoringResourceGroup
  name: '${deployment().name}-ServiceHealth'
  params: {
    ActionGroupResourceId: ((DeployMetricAlerts) || (DeployServiceHealth)) ? ActionGroup.outputs.ActionGroupResourceId : ''
    AlertPrefix: PrivateCloudName
    PrivateCloudResourceId: PrivateCloudResourceId
  }
}

module Dashboard 'Monitoring/Dashboard.bicep' = if (DeployDashboard) {
  scope: MonitoringResourceGroup
  name: '${deployment().name}-Dashboard'
  params:{
    Location: Location
    PrivateCloudResourceId: PrivateCloudResourceId
    PrivateCloudName: PrivateCloudName
  }
}

module Workbook 'Monitoring/Workbook.bicep' = if (DeployWorkbook) {
  scope: MonitoringResourceGroup
  name: '${deployment().name}-Workbook'
  params:{
    Location: Location
    Prefix: Prefix
  }
}
